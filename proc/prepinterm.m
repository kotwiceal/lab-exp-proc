function result = prepinterm(data, kwargs)
%% Prepare data to process intermittency.
%% The function takes following arguments:
%   data:               [struct]            - stucture of PIV data reterned by import_vc7 function
%   type:               [char array]        - process algorithm
%   diffilter:          [char array]        - filter type for differentiating the velocity field
%   prefilter:          [char array]        - prefiltering velocity field
%   prefiltker:         [1×2 double]        - kernel of prefilter
%   fillmissmeth:       [char array]        - method of filling missing data
%   angle:              [1×1 double]        - anlge of directed gradient [rad]git pull
%   component:          [char array]        - derivative component
%   threshold:          [1×1 logical]       - apply threshold 
%   pow:                [1×1 double]        - raise to the power of processing value
%   abs:                [1×1 logical]       - absolute value
%   eigord:             [1×1 double]        - eigen-value order
%   postfilt:           [char array]        - portfiltering of processed field
%   postfiltker:        [1×2 double]        - kernel of postfilter
%% The function returns following results:
%   result:             [n×m... double]     - prcessed field
%% Examples:
%% 1. Process a velocity directed gradient:
% data.dwdl = prepinterm(data, type = 'dirgrad');
%% 2. Process a lambda-2 criteria with custom settings:
% data.l2 = prepinterm(data, type = 'l2', diffilter = 'sobel', prefilt = 'wiener', ...
%       prefiltker = [15, 15], postfilt = 'median', postfiltker = [15, 15]);

    arguments
        data struct
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'dirgrad', 'l2', 'q', 'd', 'vm'})} = 'drigrad'
        %% preprosessing parameters
        kwargs.diffilter (1,:) char {mustBeMember(kwargs.diffilter, {'sobel', '4ord', '4ordgauss', '2ord'})} = '4ord'
        kwargs.prefilt (1,:) char {mustBeMember(kwargs.prefilt, {'none', 'gaussian', 'average', 'median', 'median-omitmissing', 'median-weighted', 'wiener', 'wiener-median', 'mode'})} = 'gaussian'
        kwargs.prefiltker double = [3, 3]
        kwargs.fillmissmeth (1,:) char {mustBeMember(kwargs.fillmissmeth, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
        kwargs.pow double = 2
        kwargs.abs logical = false
        %% dirgrad parameters
        kwargs.angle double = deg2rad(-22)
        kwargs.component (1,:) char {mustBeMember(kwargs.component, {'dudl', 'dudn', 'dwdl', 'dwdn'})} = 'dwdl'
        %% l2 parameters
        kwargs.threshold (1,:) char {mustBeMember(kwargs.threshold, {'none', 'neg', 'pos'})} = 'none'
        kwargs.eigord double = 1
        %% postprocessing parameters
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'none', 'gaussian', 'average', 'median', 'median-omitmissing', 'median-weighted', 'wiener', 'wiener-median', 'mode'})} = 'median'
        kwargs.postfiltker double = [15, 15]
    end

    result = [];

    u = data.u; w = data.w;

    % norm velocity
    if isfield(data, 'U') && isfield(data, 'W')
        Vm = hypot(data.U, data.W);
        if ~ismatrix(Vm); Vm = mean(Vm, 3); end
        u = u./Vm;
        w = w./Vm;
    end

    % fillmissing
    if kwargs.fillmissmeth ~= "none"
        sz = size(u);
        u(u == 0) = nan; w(w == 0) = nan;
        parfor i = 1:prod(sz(3:end))
            u(:,:,i) = fillmissing2(u(:,:,i), kwargs.fillmissmeth);
            w(:,:,i) = fillmissing2(w(:,:,i), kwargs.fillmissmeth);
        end
        u = reshape(u, sz); w = reshape(w, sz);
    end

    % processing
    switch kwargs.type
        case 'dirgrad'
            result = dirgrad(u, w, kwargs.angle, component = kwargs.component, diffilter = kwargs.diffilter, ...
                prefilt = kwargs.prefilt, prefiltker = kwargs.prefiltker);
            if ~isempty(kwargs.pow)
                result = result.^kwargs.pow;
            end
        case 'l2'
            result = vortind(u, w, type = 'l2', diffilter = kwargs.diffilter, prefilt = kwargs.prefilt, abs = kwargs.abs, ...
                prefiltker = kwargs.prefiltker, threshold = kwargs.threshold, pow = kwargs.pow, eigord = kwargs.eigord);
        case 'q'
            result = vortind(u, w, type = 'q', diffilter = kwargs.diffilter, prefilt = kwargs.prefilt, abs = kwargs.abs, ...
                prefiltker = kwargs.prefiltker, threshold = kwargs.threshold, pow = kwargs.pow);
        case 'd'
            result = vortind(u, w, type = 'd', diffilter = kwargs.diffilter, prefilt = kwargs.prefilt, abs = kwargs.abs, ...
                prefiltker = kwargs.prefiltker, threshold = kwargs.threshold, pow = kwargs.pow);
        case 'vm'
            result = hypot(u, w);
    end

    % postprocessing
    result = imagfilter(result, filt = kwargs.postfilt, filtker = kwargs.postfiltker);

end