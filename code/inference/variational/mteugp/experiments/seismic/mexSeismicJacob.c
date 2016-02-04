#include "mex.h"
#include <stdlib.h>

#define lk k*n_layers+l
/*
 * 
 *prhs[0] = h
 * prhs[1] = depth
 *prhs[2] = vel
 *
 *plhs[0] = dH
 *plhs[1] = dV
*/

 
void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
int n_layers;
double *h;
double *depth;
double *vel;

double val1;
double val2;


double *dH;
double *dV;

/* input */
n_layers = mxGetN(prhs[0]);
h = mxGetPr(prhs[0]);
depth = mxGetPr(prhs[1]);
vel = mxGetPr(prhs[2]);


/* output */
plhs[0] = mxCreateDoubleMatrix(n_layers,n_layers,mxREAL);
plhs[1] = mxCreateDoubleMatrix(n_layers,n_layers,mxREAL);
dH = mxGetPr(plhs[0]);  
dV = mxGetPr(plhs[1]);



for (int k = 0; k<n_layers; k++){
    for (int l = 0; l<n_layers; l++){
        for (int i = 0; i<=l; i++){
            if (i==k)
                val1 = 1;
            else
                val1 = 0;
            if ((i-1)==k)
                val2 = 1;
            else
                val2 = 0;
            
            dH[lk] = dH[lk] + 2*(val1 - val2 )/vel[i]; /* Vel here is 1 x n_layers*/
            dV[lk] = dV[lk] - 2*( val1/vel[i] ) * ( depth[i] - h[i] )/vel[i]; 
        }
    }
}

} 






























