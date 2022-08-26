# Division of Mexico City in 25 regions

---

The objective is to have a \emph{fair} division of 1255 zip-codes into 25 regions, with the property of being connected and disjoint. Our definition of a \emph{fair} division is one which achieves balance across regions in (i) number of notifications, (ii) number of addresses to be notified, and (iii) area covered. Heuristically, we proceed by joining together zip-codes while maintaining balance in the latter variables, and satisfying the constraints that such regions be connected and disjoint. Formally, we solve the following problem. 

$$
\min_{D_{kr}} \quad & \sum_{i>j} \left| Y_i-Y_j\right| \\
      \text{s.t} \;& \qquad Y_{r} =  \sum_{k}X_{k}D_{kr}\\;,  \qquad\\;\forall \\;r = 1,\ldots,25 \\
       & \qquad  1 = \sum_{r} D_{kr} \\;,  \qquad\\;\forall \\;k =1,\ldots, 1255 \\
       & \quad\\;  A_{ij} \geq D_{ir}D_{jr} \\;,  \qquad\\;\forall \\;i,j =1,\ldots, 1255 \\;,\\;\forall \\;r = 1,\ldots,25   \\
       & \qquad D_{kr} \in\{0,1\}
$$

where $k$ indexes a zip-code and $r$ indexes a region. $D_{kr}$ is a binary variable indicating whether zip-code $k$ belongs to region $r$. $X_{k}$ is an additive variable\footnote{In particular, we define it to be a weighted average of such variables for zip-code $k$ : 

$$X_k = 0.8\tilde{z}(\text{notifications})_k+0.1\tilde{z}(\text{addresses})_k+0.1\tilde{z}(\text{area})_k$$

where $$\tilde{z}$$ indicates standardization of a variable, such as (i)-(iii) above. $A_{ij}$ is an adjacency-like matrix where $A_{ij}=1$ when zip-code $i$, and $j$ are separated by no more than $v$ nodes apart. We construct matrix $A$ by applying Floyd-Warshall's algorithm to the matrix of all-pair distances of the zip-codes. Finally, $Y_r$, given by equation (2), is then the variable to be balanced across regions. Equation (3) is a constraint denoting that zip-code $k$ can only belong to one region $r$. Equation (6) is the adjacency constraint. This equation indicates that when zip-codes $i,j$ are apart, and $A_{ij}=0$, then they cannot together be in the same region. This constraint aims to achieve connectedness in each region.
Lastly, the objective function (1) seeks to minimize the accumulated difference between different regions. When the objective function is zero, we achieve perfect balance. 

This problem is easily reformulated as a MILP (Mixed-Integer-Linear-Program), we use MATLAB's \texttt{intlinprog} function to look for an (approximate) solution. Finally, we make minor manual adjustments considering the geographical constraints (such as principal avenues and highways) to ensure the regions be connected and get more straightforward notifications routes.  

---
---

# Power simulation 


We have $r=1,\ldots, 25$, $\text{Poisson}(\mu_r)$, number of cases per each day-region to be loaded for notification. Each casefile itself has a $\text{Poisson}(\mu_d)$ number of defendants. Hence, the number of "diligencias" per working day follows a compound Poisson distribution : 

$$\sum^{\sum_{r} \text{Poisson}(\mu_r)} \text{Poisson}(\mu_d)$$ 

Casefiles are assigned randomly (with probability $p_{treat}$) within regions to the treatment arm. 

Baseline probability, $p_{baseline}$, of successful notification follows a $\text{Beta}(a,b)$ distribution, with parameters calibrated such that $\mathbb{E}[p_{baseline}]=\frac{a}{a+b}$ , and $\text{V}[p_{baseline}]=\frac{ab}{(a+b)^2(a+b+1)}$. 

Moreover, each casefile has associated a region $r$, which has a differential fixed effect of $\bar{\alpha_r}$, and a notifier $n$ which has a differential fixed effect of $\bar{\gamma_n}$. 

Assignment to treatment (ATT) has a (random) treatment effect that is normally distributed $N(\mu_\beta,\sigma^2_{\beta})$. 

In sum, the model for the DGP is 

$$Y_i = 1(U[0,1]\_i < \text{Beta}(a,b)\_i + \bar{\alpha_r} + \bar{\gamma_n} + N(\mu_\beta,\sigma^2_{\beta})\_i 1(\text{Rotator}\_i))$$

and we estimate it using the following specification

$$Y_{i} = \alpha_{r}  + \beta 1(\text{Rotator}\_i) + \epsilon_{i}$$

clustering standard errors at the region level.


[Power simulation](https://github.com/isaacmeza/division_cdmx/blob/main/DoFiles/pwr_simulation.do)



![Power simulation](https://raw.githubusercontent.com/isaacmeza/division_cdmx/main/pwr_sim_graph_1.png)

