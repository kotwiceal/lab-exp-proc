function kernel = difkernel(type)
%% Process a difference schema
%% The function takes following arguments:
%   kernel: [char array]    - difference schema

    switch type
        case 'sobel'
            kernel = fspecial('sobel');
        case '4ord'
            kernel = repmat([-1, 8, 0, -8, 1]'/12, 1, 5);
        case '4ordgauss'
            kernel = repmat([-1, 8, 0, -8, 1]'/12, 1, 5).*fspecial('gaussian', [5, 5], 2);
        case '2ord'
            kernel = [1, 1, 1; -2, -2, -2, 1, 1, 1]
    end
end