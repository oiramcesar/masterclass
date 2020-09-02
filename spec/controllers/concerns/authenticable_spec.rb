require 'rails_helper'

RSpec.describe Authenticable do

  controller(ApplicationController) do
    include Authenticable
  end

  let(:app_controller) { subject }


  describe '#current_user' do
    
    let(:user) {create(:user)}

    before do
      req = double(:headers => {'Authorization'=> user.auth_token})
      allow(app_controller).to receive(:request).and_return(req)
      # req.headers['Authorization']
    end

    it 'return the user from the authorization header' do
      expect(app_controller.current_user).to eq(user)
    end

  end


  describe '#authenticate_with_token!' do

    controller do
      before_action :authenticate_with_token!

      def restricted_action;end
    end


    context 'when there is no user logged in' do

      # aqui uma definição de rota valida apenas neste contexto
      before do
        allow(app_controller).to receive(:current_user).and_return(nil)
        routes.draw { get 'restricted_action' => 'anonymous#restricted_action'}
        get :restricted_action
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'return the json data for the errors' do
        expect(json_body).to have_key(:errors)
      end

    end


  end


  describe '#user_logged_in?' do

    context 'when there is a user logged in' do

      before do
        user = create(:user)
        allow(app_controller).to receive(:current_user).and_return(:user)
      end

      it {expect(app_controller.user_logged_in?).to be true}
      
    end
    
    
    context 'when there is no user logged in' do
      
      before do
        user = create(:user)
        allow(app_controller).to receive(:current_user).and_return(nil)
      end

      it {expect(app_controller.user_logged_in?).to be false}
      
    end

  end

end

# O objetivo deste teste é relacionar o current_user a outros testes porque será utilizado como requisito para diversos outros porque é uma condição para que um determinado usuário realize uma ação.
# current_user -> procura usuario pelo token numa requisição com cabeçalho denominado authorization
# porém antes de mais nada é necessário indicar um objeto dublê para receber o token da requisição que garante que o usuário atual é o usuário logado e será permitido realizar interações no sistema.

# def current_user  
#   User.find_by(auth_token: request.headers['Authorization'])
# end
