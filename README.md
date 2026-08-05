The scripts stored in this repository are example R scripts for 
  1. Analysing multispecies catch and effort data
  2. Calcualting useful indicators for understanding fishery and ecosystem state (that can be used to help support sutainabkle fishing and ecosystem based fisheries management).

The scripts were created in support of the 2026 UN FAO document "Managing Multispecies and Multigear Fisheries – Guidance for Scientists, Managers and Stakeholders" by Leadbitter et al.

An overview of the intent of each script is given here with more detail in the individual r scripts

The first script (FAOMMSY_Tools_Data_Exploration.r) is for basic data exploration - creating plots of catch, catch composition and effort. This script explains the assumed format of the script, and the r commands to read in the data and plot it

The second script (FAOMMSY_Tools_Data_Clustering.r) is how to run simple clutering algorithms on the data to understand periods of time that have similar catch composition or fishery behaviour

The third script (FAOMMSY_Tools_Principle_Component_Analysis.r) continues this multivariate exploration of the data - finding years (and species groups) that cluster together. This can then inform on how the ecosystem has changed through time, or species that behave similarly within the fishery (correlated in the catch, these species are caught together, or increase/decrease together for example). More sophisticated analysis methods exist, but they can become increasingly hard to interpret. These simple approaches are an easier entry point.
