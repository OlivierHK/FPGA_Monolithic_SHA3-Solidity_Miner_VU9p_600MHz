#include <stdio.h>
#include <math.h>
#include <string.h>

int main ()
{

  float Fin = 120; //Fixed input Frequency.

  float Fout;//output frequency variable. What we want to achieve
  
  float phase       = 0;          // output clock phase. Zero by default.
  float Duty_Cycle  = 0.5;        //CLKOUT Duty cycle. Always 50%
  char*  s_BANDWITH = "HIGH";     //kind of desired bandwith. LOW, HIGH, OPTIMIZED.
  char* clkoutN     = "CLKOUT0";  //which CLKOUT channel to be outed.

  float Dmin = 1;// Fixed
  float Dmax = 106;// Fixed

  float Mmin = 2;// Fixed
  float Mmax = 64;// Fixed

  float Omin = 2;// Fixed
  float Omax = 128;// Fixed

  float FpfdMin = 10;// Fixed
  float FpfdMax = 500;// Fixed

  float FvcoMin = 800;// Fixed
  float FvcoMax = 1600;// Fixed


  //Using XAPP888 Formula
  float Dmin_Calc = (float) (ceil (Fin / FpfdMax));
  float Dmax_Calc = (float) (floor (Fin / FpfdMin));
  if (Dmax_Calc > Dmax){Dmax_Calc = Dmax;}

  float Mmin_Calc = (float) (ceil (FvcoMin * Dmin_Calc / Fin));
  float Mmax_Calc = (float) (floor (FvcoMax * Dmax_Calc / Fin));
  if (Mmax_Calc > Mmax){Mmax_Calc = Mmax;}

  printf ("%.0f, %.0f, %.0f, %.0f", Dmin_Calc, Dmax_Calc, Mmin_Calc, Mmax_Calc);
  printf ("\n");

  int Data_Found = 0;
  int index = 0;
  float D_Latch, M_Latch, O_Latch;

  for (float Fout_Sweep = 100; Fout_Sweep <= 800; Fout_Sweep = Fout_Sweep + 5) //Sweeping all frequency from 100MHZ to 800MHz and trying to search for solutions.
    {
      Data_Found = 0;
      for (float M = Mmax_Calc; M >= Mmin_Calc; M--) //M is the most important parameter and need to be as high as possible to be as close as possible to FvcoMax.
        {
          for (float D = Dmin_Calc; D <= Dmax_Calc; D++)  //Then D should be as low as possible
            {
              for (float O = Omin; O <= Omax; O++)  //O to finish to find the solution
                {
                Fout = (Fin * M / D / O);
                if (Fout == Fout_Sweep)//a D,M,O solution is found.
                    {
                    if (Data_Found == 0)
                      {
                         if ( (Fin * M/D <= FvcoMax) && (Fin*M/D >= FvcoMin))//double confirm we are within VCO frequency range (800-1600MHz)
                         {
                            index++;
                            //printf ("%d - Fout = %.0f, D=%.0f, M=%.0f, O=%.0f;   ", index, Fout_Sweep, D, M, O);
                            Data_Found = 1;
                            
                            //solution is latched for next frequency to check, in case of no solution found
                            D_Latch = D;
                            M_Latch = M;
                            O_Latch = O;
                         }
                      }
                    }
                }
            }
        }
        if (Data_Found == 0)//case no set of D,M,O solution found, just re-print previous set.
        {
            index++;
            //printf ("%d - Fout = %.0f, D=%.0f, M=%.0f, O=%.0f;   ", index, Fout_Sweep, D_Latch, M_Latch, O_Latch);
        }
        printf ("xapp888_drp_settings %.0f %.0f %.0f %s;    \n", M_Latch, D_Latch, phase, s_BANDWITH); //First Tcl Command. "xapp888_drp_settings <m> <d> <phase> <bw>;"
        printf ("xapp888_drp_clkout %.0f %.1f %.0f %s;  \n", O_Latch, Duty_Cycle, phase, clkoutN); //Second Tcl Command "xapp888_drp_clkout <div> <dc> <phase> clkoutN;"
        
    }
  return 0;
}