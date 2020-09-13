require 'rails_helper'

RSpec.describe 'Tasks API' do
    before { host! 'api.taskmanager.test'}

    let!(:user) {create(:user)}
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

    describe 'GET /tasks' do
      context 'when no filter is sent' do
        before do
          create_list(:task, 5, user_id: user.id)
          get '/tasks', headers: headers, params: {}
        end
        
        it 'return status code 200' do
          expect(response).to have_http_status(200)
        end
        
        it 'return 5 tasks from database' do
          expect(json_body[:data].count).to eq(5)
        end
      end
      
      context 'when filter params is sent' do
        let!(:notebook_task_1){ create(:task, title: 'Check is the notebook is open', user_id: user.id)}
        let!(:notebook_task_2){ create(:task, title: 'Buy a new notebook', user_id: user.id) }
        let!(:another_task_1){ create(:task, title: 'Fix the door', user_id: user.id) }
        let!(:anoteher_task_2){ create(:task, title: 'Buy a new car', user_id: user.id) }

        before do
         get '/tasks?q[title_cont]=note&q[s]=title+ASC', params:{}, headers: headers
        end

        it 'return only the tasks matching' do
          returned_task_titles = json_body[:data].map { |task| task[:attributes][:title] }
          expect(returned_task_titles).to eq([notebook_task_2.title, notebook_task_1.title])
        end

      end
      
    end

    describe 'GET /tasks/:id' do
      
      let(:task) { create(:task, user_id: user.id) }

      before do
        get "/tasks/#{task.id}", headers: headers, params: {}
      end 

      it 'return status code 200' do
        expect(response).to have_http_status(200)
      end
      
      it 'return the json for task' do
        expect(json_body[:data][:attributes][:title]).to eq(task.title)
      end

    end

    describe 'POST /tasks' do
      
      let(:task_params){ attributes_for(:task) }
      before do
        post "/tasks", headers: headers, params: { task: task_params }.to_json
      end 


      context 'when the params are valids' do

        it 'return status code 201' do
          expect(response).to have_http_status(201)
        end
        
        it 'save the task in the database' do
          expect(Task.find_by(title: task_params[:title])).not_to be_nil
        end

        it 'return the json for created task' do
          expect(json_body[:data][:attributes][:title]).to eq(task_params[:title])
        end      

        it 'assigns the created task to the current user' do        
          expect(json_body[:data][:attributes][:'user-id']).to eq(user.id)
        end

      end


      context 'when the params aren\'t valids' do
        # como um parâmetro inválido realiza-se a sobrescrição do titulo com valor em branco
        let(:task_params){ attributes_for(:task, title: ' ') }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)        
        end

        it 'doesn\'t save task in the database' do
          expect(Task.find_by(title: task_params[:title])).to be_nil
        end

        it 'return json error for title' do
          expect(json_body[:errors]).to have_key(:title)
        end

      end
      

    end

    describe 'PUT /tasks/:id' do
    
      let(:task) { create( :task, user_id: user.id) }
      before do
        put "/tasks/#{task.id}", headers: headers, params:{ task: task_params }.to_json
      end


      context 'when the params are valids' do
        let(:task_params){ { title: 'New title' } }

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
        
        it 'returns the json update task' do
          expect(json_body[:data][:attributes][:title]).to eq(task_params[:title])
        end

        it 'updates the task in the database' do
          expect(Task.find_by(title: task_params[:title])).not_to be_nil
        end

      end

      
      context 'when the params aren\'t valids' do

        let(:task_params){ { title: ' ' } }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
        
        it 'returns the json error title' do
          expect(json_body[:errors]).to have_key(:title)
        end

        it 'doesn\'t update the task in the database' do
          expect(Task.find_by(title: task_params[:title])).to be_nil
        end
      end

    end

    describe 'DELETE /tasks/:id' do

      let!(:task) { create(:task, user_id: user.id)}

      before do
        delete "/tasks/#{task.id}", headers:headers, params:{}
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'remove task from the database' do
        expect { Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

    end
end