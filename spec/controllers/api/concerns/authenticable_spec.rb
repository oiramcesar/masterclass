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

end

# O objetivo deste teste é relacionar o current_user a outros testes porque será utilizado como requisito para diversos outros porque é uma condição para que um determinado usuário realize uma ação.
# current_user -> procura usuario pelo token numa requisição com cabeçalho denominado authorization
# porém antes de mais nada é necessário indicar um objeto dublê para receber o token da requisição que garante que o usuário atual é o usuário logado e será permitido realizar interações no sistema.

# def current_user  
#   User.find_by(auth_token: request.headers['Authorization'])
# end
puts "****************************"