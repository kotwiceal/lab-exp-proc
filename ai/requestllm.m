function response = requestllm(content,kwargs)
    %% Chat with LLM assistant via REST API.

    arguments
        content string % request
        kwargs.url (1,:) char = 'http://localhost:11434/api/chat' % endpoint
        kwargs.model (1,:) char = 'llama3.2' % model type
        kwargs.environment (1,:) char {mustBeMember(kwargs.environment, {'cpu', 'gpu'})} = 'cpu'
        kwargs.stream (1,1) logical = false % chat mode
        kwargs.timeout (1,1) double = 60 % response timeout
        kwargs.return (1,:) char {mustBeMember(kwargs.return, {'all', 'content'})} = 'content' % parse LLM response
    end

    payload = struct(model = kwargs.model, stream = kwargs.stream, ...
        messages = {{struct(role = "user", content = content)}});
    
    options = weboptions(ContentType = 'text', MediaType = 'application/json', Timeout = kwargs.timeout);
    response = webwrite(kwargs.url, payload, options);
    response = jsondecode(response);
    switch kwargs.return
        case 'content'
            response = response.message.content;
    end
end