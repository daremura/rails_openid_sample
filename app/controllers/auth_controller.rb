require 'pathname'
require 'openid'
require 'openid/store/filesystem'

class AuthController < ApplicationController
	
	def top
	end
	
  def begin
  	# ���[�U������͂��ꂽOpenID URL������begin
  	oidreq = consumer.begin(params[:openid_url])
  	
  	# �F�؊�����ɖ߂��Ă���URL���w��
  	# �t���p�X�Ȃ̂�:only_path => false
  	return_to = url_for(:action => :complete, :only_path => false)
  	
  	# return_to�Ŏw�肷��URL�͈̔͂��w��
  	realm = "http://*." + Application::MinimalOpenidSample::config.hostname + "/"
  	
  	# �F�؃y�[�W�͂ǂ�����ĕ\�������?(���_�C���N�g or ���ڃt�H�[���̃f�[�^��\��)
  	if oidreq.send_redirect?(realm, return_to, false)
  		# ���_�C���N�g�Ȃ�redirect_to�Ŕ�΂�
      redirect_to oidreq.redirect_url(realm, return_to, false)
    else
    	# ���ڕ\���Ȃ�󂯎�����t�H�[���̃f�[�^��render����B
    	# {'id' => 'opendid_form'}�͕\������t�H�[���f�[�^�ɂ��鑮��
      render :text => oidreq.html_markup(realm, return_to, false, {'id' => 'openid_form'})
    end
    # ���̃��\�b�h�������������_�ŁA���[�U�̃u���E�U�ɂ͔F�؉�ʂ��\������Ă���
  end
	
	# ��Lbegin��return_to�Ŗ߂��URL���w�肵�Ă���̂ŁA���[�U��OpenID provider�ŔF�؂��������Ƃ�
	# ���̃��\�b�h���Ăяo�����
  def complete
  	# OpenID provider�̔F�،��ʂƈꏏ�ɁAreturn_to�Ŏw�肵��URL���߂����
  	# ���̒l�ƌ��݂�URL���r���āA����ł��邱�Ƃ����؂���K�v������
  	current_url = url_for(:action => :complete, :only_path => false)
  	
  	# params�̒l�����ɔF�،��ʂ��i�[�����I�u�W�F�N�g�𐶐����邪�A���̑O��
  	# ����URL�̏��͕K�v�����̂ŁA��菜�������̂𐶐�����
  	# Rails3�̏ꍇ�Arequest#path_parameters�̎d�l�ύX��k.to_sym�Ƃ���K�v������
  	parameters = params.reject{|k,v|request.path_parameters[k.to_sym]}
  	
  	# �F�،��ʂ̑g�ݗ��āBoidresp��ʂ��ĔF�،��ʂ��󂯎��
  	oidresp = consumer.complete(parameters, current_url)
  	
  	case oidresp.status
  		when OpenID::Consumer::SUCCESS
  			
  	
  end
  
  private
  # OpenID::Consumber�I�u�W�F�N�g�̏�����
  # �����Ő������ꂽ@consumber�I�u�W�F�N�g�́A�Z�b�V�������͕ێ������
  def consumer
    if @consumer.nil?
      dir = Pathname.new(RAILS_ROOT).join('db').join('cstore')
      store = OpenID::Store::Filesystem.new(dir)
      @consumer = OpenID::Consumer.new(session, store)
    end
    return @consumer
  end

end
