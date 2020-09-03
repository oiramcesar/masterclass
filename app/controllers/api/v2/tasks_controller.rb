class Api::V2::TasksController < ApplicationController
    before_action :authenticate_with_token!

    def index
        tasks = current_user.tasks
        render json: tasks, status: 200
    end


    def show
        # por existir serialização a partir de agora essa versão da API irá procurar na pasta do serializer os parametros, no momento da geração do serializer só existe o id.
        task = current_user.tasks.find(params[:id])
        render json: task, status: 200
    end


    def create
        # task = Task.new(user_id: current_user.id) é o mesmo que:
        task = current_user.tasks.build(task_params)
        if task.save
            render json: task, status: 201
        else
            render json: {errors: task.errors}, status: 422
        end

    end


    def update
        task = current_user.tasks.find(params[:id])
        if task.update(task_params)
            render json: task, status: 200
        else
            render json: {errors: task.errors}, status: 422
        end
    end


    def destroy
        task = current_user.tasks.find(params[:id])
        task.destroy
        head 204
    end


    private

    def task_params
        params.require(:task).permit(:title, :description, :done, :deadline)
    end
end
