require 'rails_helper'

RSpec.describe 'Users API', type: :request do
    before { host! 'api.taskmanager.test:3000'}
    let!(:user) { create(:user) }
    let(:user_id) { user.id }
    let(:headers) do
        {
            'Content-Type'=> Mime[:json].to_s,
            'Accept'=>'application/vnd.taskmanager.v2', 
            # a partir do momento que se restringe alterações pelo current_user, deve-se incluir essa chave no cabeçalho da requisição:
            'Authorization'=> user.auth_token 
        }
    end

    describe 'GET /users/:id' do
        before do
            get "/users/#{user_id}", headers: headers, params: {}
        end

        context 'when the user exists' do
            it 'returns the user' do
                expect(json_body[:id]).to eq(user_id)
            end

            it 'returns status code 200' do
                expect(response).to have_http_status(200)
            end
        end
        1
        context 'when the user doesn\'t exists' do
            let(:user_id) { 1000 }

            it 'returns status code 404' do
                expect(response).to have_http_status(404)
            end
        end

    end

    describe 'POST /users' do
        before do
            post '/users', headers: headers, params:{user: user_params}.to_json
        end

        context 'when the request params are valids' do
            let(:user_params){ attributes_for(:user)}

            it 'returns status code 201' do
                expect(response).to have_http_status(201)
            end

            it 'return JSON data for created user' do
                expect(json_body[:email]).to eq(user_params[:email])
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

    describe 'PUT /users/:id' do
        before do
            put "/users/#{user_id}", headers: headers, params:{user: user_params}.to_json
        end

        context 'when the request params are valid' do
            let(:user_params) { { email: 'new_email@taskmanager.com' } }
            
            it 'returns status code 200' do
                expect(response).to have_http_status(200)
            end

            it 'return JSON data with update information' do
                expect(json_body[:email]).to eq(user_params[:email])
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

    describe 'DELETE /users/:id' do
        before do
            delete "/users/#{user_id}", headers: headers, params:{}
        end

        it 'returns status code 204' do
            expect(response).to have_http_status(204)
        end

        it 'removes the user from database' do
            expect(User.find_by(id: user.id)).to be_nil
        end

    end

end