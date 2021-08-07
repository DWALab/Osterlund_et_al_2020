## Extracting G-Factor from Tethered Fluorescent Protein FLIM-HS Scans
Photon and intensity measurements for ROIs collected from donor-acceptor tethered constructes can be downloaded from the following link:<br/>
https://doi.org/10.5683/SP2/TIPUGZ <br/>
The G-Factor is a measure of how much increase is observed in the acceptor intensity due to FRET. Since our acceptor fluorescence signal is collected using a non-temporally resolved detector, we are not able to directly determine the total acceptor concentration using T0 and protein gradient. Thus, we need to correct of observed increase in acceptor intensity due to FRET. 
Expressing our acceptor and donor fluorescent proteins tethered together ensures that their concentration is the same in the cell. Varying the number of amino acids ensures that on average there is different amount of FRET occurring between donor an acceptor. 
Unlike previously reported methods, we calculate the G-Factor in the concentration space. Therefore, photon count and intensity measures, from our FLIM and HS channels respectively, need to be converted to concentration values. We utilize the protein gradient standard curves to perform this conversion.
<br>
1. Prepare a 384-well plate containing the mCerulean3 protein gradient, Venus protein gradient, cells expressing mCerulean3 only, cells expressing Venus protein only, and cells expressing tethered fluorescent proteins with varying linker size. 
2. Create a plate map using excel to keep track of experimental conditions and well IDs. 
3. Image cells expressing tethered fluorescent proteins and collect FLIM-HS data. The imaging conditions such as plate type, laser powers, optical filter, and acquisition parameters must be identical to those used in the screen. Note it is recommended to perform these measurements as often as possible to account for instrumental and laser drift effects.
4. For the protein gradient scans generate gradient slope. The analysis will yield two values, the mCerulean3 gradient slope and the Venus gradient slope.
5. For the tethered cell samples, run the segmentation analysis, and generate CSV files which contain FLIM and spectral profiles for each ROI. 
6. Copy the generated CSVs into a single path while noting the well IDs for the different linker constructs. 
7. Download the script “GFactorByMultipleCSVs.m”. 
8. Copy the data path created in step 6 and update the data_path parameter in the script. 
9. Update mc3_slope and Venus _slope values obtained from step 4. 
10. Update the mc3_only_well_id, and the different constructs well IDs. In our case we have 4 constructs with varying amino acid lengths.
11.	Run the script. <br/>
The script will first open the mCerulean3 only wells to determine bleedthrough into the acceptor channel and the lifetime of mCerulean3 expressed in cells. To reduce noise effects on estimated lifetime only analyze ROI profiles that have, on average, mCerulean3 concentrations equal to and above 1 µM and lower than 5 µM. The script will generate a 3D plot for FRET vs total mCerulean3 concentrations and total Venus concentration. This profile is fit to estimate the G-factor.
12.	Optional Step:  change the upper and lower bound concentration parameters for mCerulean3 if you find the plot too noisy of you prefer to widen the concentration range analyzed. 
