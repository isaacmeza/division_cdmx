# Division of Mexico City in 25 regions

The objective is to have a \emph{fair} division of 1255 zip-codes into 25 regions, with the property of being connected and disjoint. Our definition of a \emph{fair} division is one which achieves balance across regions in (i) number of notifications, (ii) number of addresses to be notified, and (iii) area covered. Heuristically, we proceed by joining together zip-codes while maintaining balance in the latter variables, and satisfying the constraints that such regions be connected and disjoint. Formally, we solve the following problem. 

\begin{align}
    \min_{D_{kr}} \quad & \sum_{i>j} \left| Y_i-Y_j\right| \\
      \text{s.t} \;& \qquad Y_{r} =  \sum_{k}X_{k}D_{kr}\;,  \qquad\;\forall \;r = 1,\ldots,25 \\
       & \qquad  1 = \sum_{r} D_{kr} \;,  \qquad\;\forall \;k =1,\ldots, 1255 \\
       & \quad\;  A_{ij} \geq D_{ir}D_{jr} \;,  \qquad\;\forall \;i,j =1,\ldots, 1255 \;,\;\forall \;r = 1,\ldots,25   \\
       & \qquad D_{kr} \in\{0,1\}
\end{align}

where $k$ indexes a zip-code and $r$ indexes a region. $D_{kr}$ is a binary variable indicating whether zip-code $k$ belongs to region $r$. $X_{k}$ is an additive variable\footnote{In particular, we define it to be a weighted average of such variables for zip-code $k$ : 
$$X_k = 0.8\widetilde{z}(\text{\# of notifications})_k+0.1\widetilde{z}(\text{\# of addresses})_k+0.1\widetilde{z}(\text{area (km}^2))_k$$
where $\widetilde{z(\cdot)}$ indicates standardization of variable $(\cdot)$.} such as (i)-(iii) above. $A_{ij}$ is an adjacency-like matrix where $A_{ij}=1$ when zip-code $i$, and $j$ are separated by no more than $v$ nodes apart. We construct matrix $A$ by applying Floyd-Warshall's algorithm to the matrix of all-pair distances of the xip-codes. Finally, $Y_r$, given by equation (2), is then the variable to be balanced across regions. Equation (3) is a constraint denoting that zip-code $k$ can only belong to one region $r$. Equation (6) is the adjacency constraint. This equation indicates that when zip-codes $i,j$ are apart, and $A_{ij}=0$, then they cannot together be in the same region. This constraint aims to achieve connectedness in each region.
Lastly, the objective function (1) seeks to minimize the accumulated difference between different regions. When the objective function is zero, we achieve perfect balance. \\

This problem is easily reformulated as a MILP (Mixed-Integer-Linear-Program), we use MATLAB's \texttt{intlinprog} function to look for an (approximate) solution. Finally, we make minor manual adjustments considering the geographical constraints (such as principal avenues and highways) to ensure the regions be connected and get more straightforward notifications routes.  