require 'rails_helper'

RSpec.describe 'Tasks API' do
    before { host! 'api.taskmanager.test'}

    let!(:user) {create(:user)}

    let(:headers) do
    {
        'Content-Type' => Mime[:json].to_s,
        'Accept' => 'application/vnd.taskmanager.v1',
        'Authorization' => user.auth_token
    }
    end

    describe 'GET /tasks' do
      before do
        create_list(:task, 5, user_id: user.id)
        get '/tasks', headers: headers, params: {}
      end

      it 'return status code 200' do
        expect(response).to have_http_status(200)
      end
      
      it 'return 5 tasks from database' do
        expect(json_body[:tasks].count).to eq(5)
      end

    end
end