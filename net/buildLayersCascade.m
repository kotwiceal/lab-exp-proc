function layers = buildLayersCascade(kwargs)
    arguments
        kwargs.levels (1,:) char = 'x2'
        kwargs.insize (1,3) uint32 = [270, 320, 1]
        kwargs.numclass (1,1) uint32 = 2
        kwargs.normalization (1,:) char {mustBeMember(kwargs.normalization, {'none', 'zerocenter', 'zscore'})} = 'none'
    end

    switch kwargs.levels
        case 'x2'
            layers = @(kersize, kernum, kerstrd) [
                imageInputLayer(kwargs.insize, 'Normalization', kwargs.normalization)
            
                convolution2dLayer(kersize{1}, kernum{1}, Stride = kerstrd{1})
                batchNormalizationLayer
                reluLayer
            
                transposedConv2dLayer(kersize{1}, kernum{1}, Stride = kerstrd{1})
                batchNormalizationLayer
                reluLayer
            
                convolution2dLayer(1, kwargs.numclass)
                softmaxLayer
            ];
        case 'x4'
            layers = @(kersize, kernum, kerstrd) [
                imageInputLayer(kwargs.insize, 'Normalization', kwargs.normalization)
            
                convolution2dLayer(kersize{1}, kernum{1}, Stride = kerstrd{1})
                batchNormalizationLayer
                reluLayer
            
                convolution2dLayer(kersize{2}, kernum{2}, Stride = kerstrd{2})
                batchNormalizationLayer
                reluLayer
            
                transposedConv2dLayer(kersize{2}, kernum{2}, Stride = kerstrd{2})
                batchNormalizationLayer
                reluLayer
            
                transposedConv2dLayer(kersize{1}, kernum{1}, Stride = kerstrd{1})
                batchNormalizationLayer
                reluLayer
            
                convolution2dLayer(1, kwargs.numclass)
                softmaxLayer
            ];
        case 'x6'
            layers = @(kersize, kernum, kerstrd) [
                imageInputLayer(kwargs.insize, 'Normalization', kwargs.normalization)
            
                convolution2dLayer(kersize{1}, kernum{1}, Stride = kerstrd{1})
                batchNormalizationLayer
                reluLayer
            
                convolution2dLayer(kersize{2}, kernum{2}, Stride = kerstrd{2})
                batchNormalizationLayer
                reluLayer
            
                convolution2dLayer(kersize{3}, kernum{3}, Stride = kerstrd{3})
                batchNormalizationLayer
                reluLayer
            
                transposedConv2dLayer(kersize{3}, kernum{3}, Stride = kerstrd{3})
                batchNormalizationLayer
                reluLayer
            
                transposedConv2dLayer(kersize{2}, kernum{2}, Stride = kerstrd{2})
                batchNormalizationLayer
                reluLayer
            
                transposedConv2dLayer(kersize{1}, kernum{1}, Stride = kerstrd{1})
                batchNormalizationLayer
                reluLayer
            
                convolution2dLayer(1, kwargs.numclass)
                softmaxLayer
            ];
        case 'x8'
            layers = @(kersize, kernum, kerstrd) [
                imageInputLayer(kwargs.insize, 'Normalization', kwargs.normalization)
            
                convolution2dLayer(kersize{1}, kernum{1}, Stride = kerstrd{1})
                batchNormalizationLayer
                reluLayer
            
                convolution2dLayer(kersize{2}, kernum{2}, Stride = kerstrd{2})
                batchNormalizationLayer
                reluLayer
            
                convolution2dLayer(kersize{3}, kernum{3}, Stride = kerstrd{3})
                batchNormalizationLayer
                reluLayer

                convolution2dLayer(kersize{4}, kernum{4}, Stride = kerstrd{4})
                batchNormalizationLayer
                reluLayer

                transposedConv2dLayer(kersize{4}, kernum{4}, Stride = kerstrd{4})
                batchNormalizationLayer
                reluLayer

                transposedConv2dLayer(kersize{3}, kernum{3}, Stride = kerstrd{3})
                batchNormalizationLayer
                reluLayer
            
                transposedConv2dLayer(kersize{2}, kernum{2}, Stride = kerstrd{2})
                batchNormalizationLayer
                reluLayer
            
                transposedConv2dLayer(kersize{1}, kernum{1}, Stride = kerstrd{1})
                batchNormalizationLayer
                reluLayer
            
                convolution2dLayer(1, kwargs.numclass)
                softmaxLayer
            ];
    end

end