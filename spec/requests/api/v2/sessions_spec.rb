require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do

  before { host! 'api.taskmanager.test'}
  
  let!(:user) { create(:user) }
  let!(:auth_data) { user.create_new_auth_token }

	let(:headers) do
		{
			'Content-Type' => Mime[:json].to_s,
			'Accept' => 'application/vnd.taskmanager.v2',
			'access-token' => auth_data['access-token'],
			'uid' => auth_data['uid'],
			'client' => auth_data['client'],
		 }
	end

	describe 'POST /auth/sign_in' do
		before do
			post '/auth/sign_in', headers: headers, params: credentials.to_json
		end

		context 'when the credentials are correct' do
			let(:credentials) { { email: user.email, password: '123456' } }

			it 'returns status code 200' do
				expect(response).to have_http_status(200)
			end

      it 'returns the authentication data in the headers' do        
        expect(response.headers).to have_key('access-token')
        expect(response.headers).to have_key('uid')
        expect(response.headers).to have_key('client')
			end
		end

		context 'when the credentials are incorrect' do
			let(:credentials) { { email: user.email, password: 'invalid_password' } }

			it 'returns status code 401' do
				expect(response).to have_http_status(401)
			end

			it 'returns the json data for the errors' do
				expect(json_body).to have_key(:errors)
			end
		end

	end

	describe 'DELETE /auth/sign_out' do
		let(:auth_token){ user.auth_token }

		before do
			delete '/auth/sign_out', headers: headers, params:{}
		end

		it 'return status code 200' do
			expect(response).to have_http_status(200)
		end

    it 'changes de user auth token' do
      user_has_new_token = user.reload.valid_token?(auth_data['access-token'], auth_data['client'])
      expect(user_has_new_token).to be_falsey
      # refreshed = user.reload.valid_token?(auth_data['access-token'], auth_data['client'])
			# expect(user).not_to be_valid_token(refreshed)
		end

	end

end