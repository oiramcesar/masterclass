require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  before { host! 'api.taskmanager.test:3000'}
  let!(:user) { create(:user) }
  let!(:auth_data) { user.create_new_auth_token }
  let(:headers) do
    {
      'Accept'=>'application/vnd.taskmanager.v2', 
      'access-token' => auth_data['access-token'],
      'uid' => auth_data['uid'],
      'client' => auth_data['client'],
      'Content-Type'=> Mime[:json].to_s
    }
  end

  describe 'GET /auth/validate_token' do
      
    context 'when the request headers are valids' do

      before do
        get '/auth/validate_token', headers: headers, params: {}
      end            
      
      it 'returns the user id' do
        expect(json_body[:data][:id].to_i).to eq(user.id)
      end
      
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

    end
      
    context 'when the request headers aren\'t valids' do

      before do
        # ocorre neste sentido a sopreposição do valor de um header através da linha a seguir:
        headers['access-token'] = 'invalid-token'
        get '/auth/validate_token', headers: headers, params: {}
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(401)
      end

    end

  end

  describe 'POST /auth' do
    before do
      post '/auth', headers: headers, params: user_params.to_json
    end

    context 'when the request params are valids' do
      let(:user_params){ attributes_for(:user)}

      it 'returns status code 200' do
          expect(response).to have_http_status(200)
      end

      it 'return JSON data for created user' do
          expect(json_body[:data][:email]).to eq(user_params[:email])
      end
    end

    context 'when the request params are invalids' do
      let(:user_params){ attributes_for(:user, email: 'Invalid_email@')}

      it 'returns status code 422' do
          expect(response).to have_http_status(422)
      end

      it 'return JSON data with errors' do
          expect(json_body).to have_key(:errors)
      end

    end

  end

  describe 'PUT /auth' do
    before do
      put '/auth', headers: headers, params:user_params.to_json
    end

    context 'when the request params are valid' do
      let(:user_params) { { email: 'new_email@taskmanager.com' } }
      
      it 'returns status code 200' do
          expect(response).to have_http_status(200)
      end

      it 'return JSON data with update information' do
          expect(json_body[:data][:email]).to eq(user_params[:email])
      end

    end
    
    context 'when the request params are invalid' do
      let(:user_params) { { email: 'New_email@' } }
      
      it 'returns status code 422' do
          expect(response).to have_http_status(422)
      end

      it 'return JSON data with errors' do
          expect(json_body).to have_key(:errors)
      end
    end
  end

  describe 'DELETE /auth' do
    before do
      delete '/auth', headers: headers, params:{}
    end

    it 'returns status code 204' do
      expect(response).to have_http_status(200)
    end

    it 'removes the user from database' do
      expect(User.find_by(id: user.id)).to be_nil
    end

  end

end