require 'pathname'
require 'openid'
require 'openid/store/filesystem'

class AuthController < ApplicationController
	
	def top
	end
	
  def begin
  	# ユーザから入力されたOpenID URLを元にbegin
  	oidreq = consumer.begin(params[:openid_url])
  	
  	# 認証完了後に戻ってくるURLを指定
  	# フルパスなので:only_path => false
  	return_to = url_for(:action => :complete, :only_path => false)
  	
  	# return_toで指定するURLの範囲を指定
  	realm = "http://*." + Application::MinimalOpenidSample::config.hostname + "/"
  	
  	# 認証ページはどうやって表示される?(リダイレクト or 直接フォームのデータを表示)
  	if oidreq.send_redirect?(realm, return_to, false)
  		# リダイレクトならredirect_toで飛ばす
      redirect_to oidreq.redirect_url(realm, return_to, false)
    else
    	# 直接表示なら受け取ったフォームのデータをrenderする。
    	# {'id' => 'opendid_form'}は表示するフォームデータにつける属性
      render :text => oidreq.html_markup(realm, return_to, false, {'id' => 'openid_form'})
    end
    # このメソッドが完了した時点で、ユーザのブラウザには認証画面が表示されている
  end
	
	# 上記beginのreturn_toで戻りのURLを指定しているので、ユーザがOpenID providerで認証をしたあとは
	# このメソッドが呼び出される
  def complete
  	# OpenID providerの認証結果と一緒に、return_toで指定したURLも戻される
  	# その値と現在のURLを比較して、同一であることを検証する必要がある
  	current_url = url_for(:action => :complete, :only_path => false)
  	
  	# paramsの値を元に認証結果を格納したオブジェクトを生成するが、その前に
  	# このURLの情報は必要無いので、取り除いたものを生成する
  	# Rails3の場合、request#path_parametersの仕様変更でk.to_symとする必要がある
  	parameters = params.reject{|k,v|request.path_parameters[k.to_sym]}
  	
  	# 認証結果の組み立て。oidrespを通じて認証結果を受け取る
  	oidresp = consumer.complete(parameters, current_url)
  	
  	case oidresp.status
  		when OpenID::Consumer::SUCCESS
  			
  	
  end
  
  private
  # OpenID::Consumberオブジェクトの初期化
  # ここで生成された@consumberオブジェクトは、セッション中は保持される
  def consumer
    if @consumer.nil?
      dir = Pathname.new(RAILS_ROOT).join('db').join('cstore')
      store = OpenID::Store::Filesystem.new(dir)
      @consumer = OpenID::Consumer.new(session, store)
    end
    return @consumer
  end

end
