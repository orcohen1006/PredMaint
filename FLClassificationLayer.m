classdef FLClassificationLayer < nnet.layer.ClassificationLayer
               
    properties
        
        % Gamma (scalar positive real) is the focusing parameter.
        Gamma

        % Alpha (scalar positive real) is the balancing parameter.
        Alpha

    end

    methods
        function layer = FLClassificationLayer(alpha , gamma)
            % layer = weightedClassificationLayer(classWeights) creates a
            % weighted cross entropy loss layer. classWeights is a row
            % vector of weights corresponding to the classes in the order
            % that they appear in the training data.
            % 
            % layer = weightedClassificationLayer(classWeights, name)
            % additionally specifies the layer name. 

            % Set class weights
            
            layer.Alpha = alpha;
            layer.Gamma = gamma;

            % Set layer description
            layer.Description = 'focal loss';
        end
        
        function loss = forwardLoss(layer, Y, T)
            % loss = forwardLoss(layer, Y, T) returns the weighted cross
            % entropy loss between the predictions Y and the training
            % targets T.

%             N = size(Y,4);
            N = size(Y,2);                
            Y = squeeze(Y);
            T = squeeze(T);
%             W = layer.ClassWeights;
%             loss_CE = -sum(W*(T.*log(Y)))/N;

            loss_FL = sum( T .* layer.Alpha .*((1 - Y).^layer.Gamma).* log(Y), 3);
            loss_FL = (-1/N) * sum(loss_FL(:));
            
            loss = loss_FL;
        end
        
        function dLdY = backwardLoss(layer, Y, T)
            % dLdY = backwardLoss(layer, Y, T) returns the derivatives of
            % the weighted cross entropy loss with respect to the
            % predictions Y.

%             [~,~,K,N] = size(Y);
            [K,N] = size(Y);
            Y = squeeze(Y);
            T = squeeze(T);
%             W = layer.ClassWeights;
%             dX_CE = -(W'.*T./Y)/N;
            
            dX_FL = layer.Alpha .* T .* ( ...
                 +(layer.Gamma .* (1 - Y).^(layer.Gamma-1) .* log(Y)) ...
                 -((1 - Y).^layer.Gamma ./ (Y)) ...
                 ) ./ N;

            
            dLdY = dX_FL;
%             dLdY = reshape(dLdY,[1 1 K N]);
        end
    end
end