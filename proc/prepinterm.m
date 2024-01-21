function result = prepinterm(data, kwargs)

    arguments
        data struct
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'dirgrad', 'l2'})} = 'drigrad'
        % preprosessing parameters
        kwargs.diffilter (1,:) char {mustBeMember(kwargs.diffilter, {'sobel', '4ord', '4ordgauss', '2ord'})} = '4ord'
        kwargs.prefilter (1,:) char {mustBeMember(kwargs.prefilter, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'gaussian'
        kwargs.prefiltkernel double = [3, 3]
        % dirgrad parameters
        kwargs.angle double = deg2rad(-22)
        kwargs.component (1,:) char {mustBeMember(kwargs.component, {'dudl', 'dudn', 'dwdl', 'dwdn'})} = 'dwdl'
        % postprocessing parameters
        kwargs.postfitler (1,:) char {mustBeMember(kwargs.postfitler, {'median-wiener', 'gaussian', 'average'})} = 'median-wiener'
        kwargs.postfiltkernel double = [10, 10]
    end

    result = [];

    % normalize velocity
    if isfield(data, 'U') && isfield(data, 'W')
        Vm = hypot(data.U, data.W);
        u = data.u./Vm;
        w = data.w./Vm;
    else
        u = data.u;
        w = data.w; 
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
        case 'gaussian'
            result = imfilter(result, fspecial(kwargs.postfitler, kwargs.postfiltkernel));
    end

end