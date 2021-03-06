%   The algorithms implemented by Alexander Vezhnevets aka Vezhnick
%   <a>href="mailto:vezhnick@gmail.com">vezhnick@gmail.com</a>
%
%   Copyright (C) 2005, Vezhnevets Alexander
%   vezhnick@gmail.com
%   
%   This file is part of GML Matlab Toolbox
%   For conditions of distribution and use, see the accompanying License.txt file.
%   
%   GentleAdaBoost Implements boosting process based on "Gentle AdaBoost"
%   algorithm
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%    [Learners, Weights, final_hyp] = GentleAdaBoost(WeakLrn, Data, Labels,
%    Max_Iter, OldW, OldLrn, final_hyp)
%    ---------------------------------------------------------------------------------
%    Arguments:
%           WeakLrn   - weak learner
%           Data      - training data. Should be DxN matrix, where D is the
%                       dimensionality of data, and N is the number of
%                       training samples.
%           Labels    - training labels. Should be 1xN matrix, where N is
%                       the number of training samples.
%           Max_Iter  - number of iterations
%           OldW      - weights of already built commitee (used for training 
%                       of already built commitee)
%           OldLrn    - learnenrs of already built commitee (used for training 
%                       of already built commitee)
%           final_hyp - output for training data of already built commitee 
%                       (used to speed up training of already built commitee)
%    Return:
%           Learners  - cell array of constructed learners 
%           Weights   - weights of learners
%           final_hyp - output for training data

function [Learners, Weights, final_hyp] = GentleAdaBoost2KO(WeakLrn, Data, Labels, Max_Iter, OldW, OldLrn, final_hyp)

global GE_min;

if( nargin == 4)
  Learners = {};
  Weights = [];
  distr = ones(1, size(Data,2)) / size(Data,2);  
  final_hyp = zeros(1, size(Data,2));
elseif( nargin > 5)
  Learners = OldLrn;
  Weights = OldW;
  if(nargin < 7)
    final_hyp = Classify(Learners, Weights, Data);
  end
  distr = exp(- (Labels .* final_hyp));  
  distr = distr / sum(distr);  
else
  error('Function takes eather 4 or 6 arguments');
end


for It = 1 : Max_Iter
  
  %chose best learner

  nodes = train2(WeakLrn, Data, Labels, distr);

  %for i = 1:length(nodes)
    curr_tr = nodes;
    
      %Feature KO
      pos=find(Labels>0);
      neg=find(Labels<0);
      posRatio=length(pos)/(length(neg)+length(pos));
      
      if(rand>posRatio)
          randomsample1=ceil(rand*(length(pos)-1))+1;
          randomsample2=ceil(rand*(length(neg)-1))+1;

          dim=GetDim(curr_tr);

          Data(:,end+1)=Data(:,pos(randomsample1));
          Data(dim,end)=Data(dim,neg(randomsample2));
          Labels(end+1)=Labels(pos(randomsample1));
          distr(end+1)=distr(pos(randomsample1));
          final_hyp(end+1)=final_hyp(pos(randomsample1));
      else
          randomsample1=ceil(rand*(length(neg)-1))+1;
          randomsample2=ceil(rand*(length(pos)-1))+1;

          dim=GetDim(curr_tr);

          Data(:,end+1)=Data(:,neg(randomsample1));
          Data(dim,end)=Data(dim,pos(randomsample2));
          Labels(end+1)=Labels(neg(randomsample1));
          distr(end+1)=distr(neg(randomsample1));
          final_hyp(end+1)=final_hyp(neg(randomsample1));
      end
%   end Feature KO
    
    step_out = calc_output(curr_tr, Data); 
      
    s1 = sum( (Labels ==  1) .* (step_out) .* distr);
    s2 = sum( (Labels ==  1) .* (1-step_out) .* distr);
    s3 = sum( (Labels ==  -1) .* (1-step_out) .* distr);
    s4 = sum( (Labels ==  -1) .* (step_out) .* distr);

    if(s1 == 0 && s2 == 0)
        continue;
    end
    Alpha = (s1-s4)/(s1+s4)+(s3-s2)/(s2+s3);

    Weights(end+1) = Alpha;
    
    Learners{end+1} = curr_tr;
    
    final_hyp = final_hyp + step_out .* Alpha;    
  %end
  
  Z = sum(abs(Labels .* final_hyp));
  
  if(Z == 0)
    Z = 1;
  end
  
  distr = exp(- 1 * (Labels .* final_hyp) / Z);
  Z = sum(distr);
  distr = distr / Z;  

end
