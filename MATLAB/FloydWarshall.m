% FloydWarshall - Compute the all pairs shortest path matrix
% 
% http://en.wikipedia.org/wiki/Floyd_Warshall
% 
% USAGE:
%
% D = FloydWarshall(A)
% 
% D - the distance (neighbours) matrix.
% A - the adjacency matrix, where A(i,j) is the unit distance for moving from vertex i to
%     vertex j.  
%      

function V = FloydWarshall(V)
   
    %input matrix must be initialized properly -- A(i,j) = Inf if i and j are not neighbors.
    V(V==0) = inf; 
	n = length(V);   
    
    for k = 1:n      
		i2k = repmat(V(:,k), 1, n);
		k2j = repmat(V(k,:), n, 1);
		V = min(V, i2k+k2j);                         
    end
    
end