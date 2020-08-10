class ApiVersionConstraint
    def initialize(options)
        @version = options[:version]
        @default = options[:default]
    end
    
    def matches?(req)
        @default || req.headers['Accept'].include?("application/vnd.task-manager.v#{@version}")
    end 
end
