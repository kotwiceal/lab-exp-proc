function result = prepinterm(data, kwargs)
%% Prepare data to process intermittency.
%% The function takes following arguments:
%   data:               [struct]            - stucture of PIV data reterned by import_vc7 function
%   type:               [char array]        - process algorithm
%   diffilter:          [char array]        - filter type for differentiating the velocity field
%   prefilter:          [char array]        - prefiltering velocity field
%   prefiltkernel:      [1×2 double]        - kernel of prefilter
%   angle:              [1×1 double]        - anlge of directed gradient [rad]
%   component:          [char array]        - derivative component
%   postfitler:         [char array]        - portfiltering of processed field
%   postfiltkernel:     [1×2 double]        - kernel of postfilter
%% The function returns following results:
%   result:             [n×m... double]     - prcessed field
%% Examples:
%% process a velocity directed gradient
% data.dwdl = prepinterm(data, type = 'dirgrad');
%% process a lambda-2 criteria with custom settings
% data.dwdl = prepinterm(data, type = 'l2', diffilter = 'sobel', prefilter = 'wiener', ...
%       prefiltkernel = [15, 15], postfitler = 'median', postfiltkernel = [15, 15]);

    arguments
        data struct
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'dirgrad', 'l2', 'vm'})} = 'drigrad'
        % preprosessing parameters
        kwargs.diffilter (1,:) char {mustBeMember(kwargs.diffilter, {'sobel', '4ord', '4ordgauss', '2ord'})} = '4ord'
        kwargs.prefilter (1,:) char {mustBeMember(kwargs.prefilter, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'gaussian'
        kwargs.prefiltkernel double = [3, 3]
        kwargs.fillmissmeth (1,:) char {mustBeMember(kwargs.fillmissmeth, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
        % dirgrad parameters
        kwargs.angle double = deg2rad(-22)
        kwargs.component (1,:) char {mustBeMember(kwargs.component, {'dudl', 'dudn', 'dwdl', 'dwdn'})} = 'dwdl'
        % postprocessing parameters
        kwargs.postfitler (1,:) char {mustBeMember(kwargs.postfitler, {'none', 'median', 'wiener', 'median-wiener', 'gaussian', 'average'})} = 'median-wiener'
        kwargs.postfiltkernel double = [10, 10]
    end

    result = [];

    u = data.u; w = data.w;

    % normalize velocity
    if isfield(data, 'U') && isfield(data, 'W')
        Vm = hypot(data.U, data.W);
        u = u./Vm;
        w = w./Vm;
    end

    % fillmissing
    if kwargs.fillmissmeth ~= "none"
        sz = size(u);
        u = reshape(u, [sz(1:2), prod(sz(3:end))]);
        w = reshape(w, [sz(1:2), prod(sz(3:end))]);
        parfor i = 1:prod(sz(3:end))
            u(:,:,i) = fillmissing2(u(:,:,i), kwargs.fillmissmeth);
            w(:,:,i) = fillmissing2(w(:,:,i), kwargs.fillmissmeth);
        end
        u = reshape(u, sz); w = reshape(w, sz);
    end

    % process
    switch kwargs.type
        case 'dirgrad'
            result = dirgrad(u, w, kwargs.angle, component = kwargs.component, diffilter = kwargs.diffilter, ...
                prefilter = kwargs.prefilter, prefiltkernel = kwargs.prefiltkernel);
            result = result.^2;
        case 'l2'
            result = vortind(u, w, type = 'l2', diffilter = kwargs.diffilter, prefilter = kwargs.prefilter, ...
                prefiltkernel = kwargs.prefiltkernel);
        case 'vm'
            result = hypot(u, w);
    end

    % postprocessing
    switch kwargs.postfitler
        case 'median-wiener'
            for i = 1:size(result, 3)
                result(:,:,i) = medfilt2(result(:,:,i), kwargs.postfiltkernel);
            end
            for i = 1:size(result, 3)
                result(:,:,i) = wiener2(result(:,:,i), kwargs.postfiltkernel);
            end
        case 'median'
            for i = 1:size(result, 3)
                result(:,:,i) = medfilt2(result(:,:,i), kwargs.postfiltkernel);
            end
        case 'wiener'
            for i = 1:size(result, 3)
                result(:,:,i) = wiener2(result(:,:,i), kwargs.postfiltkernel);
            end
        case 'gaussian'
            result = imfilter(result, fspecial(kwargs.postfitler, kwargs.postfiltkernel));
        case 'average'
            result = imfilter(result, fspecial(kwargs.postfitler, kwargs.postfiltkernel));
    end

end