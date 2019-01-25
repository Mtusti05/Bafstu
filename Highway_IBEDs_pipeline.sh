#!/bin/bash
# show usage information
if [ "${1}" == "--h" ] || [ "${1}" == "--help" ] || [ "${1}" == "-h" ] || [ "${1}" == "-help" ]
	then
		echo " " 
		echo "This pipeline analyzes RAD_seq data. It expects input files containing raw reads."
		echo "The pipeline returns files with RAD-tags for each sample." 
		echo "Highway_IBEDs_STACK_pipeline.sh runs diferen et components of the pipeline."
		echo "These componenets are: process_radtags, build loci etcccccc." 
		echo "" 
		echo "Way of usage (stand-alone) for paired-end reads:" 
		echo "bash Highway_IBEDs_STACK_pipeline.sh <inputfile1> <inputfile2>" 
		echo ""
		echo "Way of usage (stand-alone) for single end reads:"
		echo "bash Highway_IBEDs_STACK_pipeline.sh  <inputfile>"
		echo ""
		echo "The run time can be recorded with the following command:" 
		echo "time bash Highway_IBEDs_STACK_pipeline.sh <inputfile1> <inputfile2>"
		echo "time bash Highway_IBEDs_STACK_pipeline.sh <inputfile>"   
		echo ""  
	exit
fi
# IF 13 = true, paired data 
if [ "$#" -eq 17 ]; then
    DATE=$(date +"%d%m%Y")
    N=1

    # Increment $N as long as a directory with that name exists                           
    while [[ -d "${4}/Clean_$DATE-$N" ]] ; do
        N=$(($N+1))
    done
bash prep_IBEDs_pipeline.sh "${1}" "${2}" "${3}" "${4}" ${5} ${6} ${7} ${8} ${9} ${10} ${11}
Rscript initial_reads_IBEDs_pipeline.R "Values_run_total_reads_bf_process.txt" ${4}/"Clean_$DATE-$N" --quiet 2>&1 >/dev/null
echo "A plot containing the initial number of reads before process_radtags can be found in the following directoty ${4}/"Clean_$DATE-$N""
file=$(ls ${16} | egrep -m 1 ".bt2")
ref_index=${file::${#file}-6}
echo $ref_index
while read col1
do
names=$(echo $col1 | awk '{print $2}') 
bowtie2 -x ${16}/$ref_index -1 ${4}/"Clean_$DATE-$N"/${names}.1.fq -2 ${4}/"Clean_$DATE-$N"/${names}.2.fq -S ${4}/"Clean_$DATE-$N"/${names}.sam 2> ${4}/"Clean_$DATE-$N"/${names}_alignment.log
done < ${3}
fi
#ref_map.pl -T 15 -o ./ --popmap ../Popmap_17_dec_selection.txt --samples ../bowtie_forward  -X "populations:--vcf" 2> log_ref_map_11_12.txt
if [ "$#" -eq 16 ] && [ "${16}" -eq 2 ]; then
   echo "ref single high"
fi 
if [ "$#" -eq 16 ] && [ "${16}" -eq 4 ]; then
    DATE=$(date +"%d%m%Y")
    N=1

    # Increment $N as long as a directory with that name exists                           
    while [[ -d "${4}/Clean_$DATE-$N" ]] ; do
        N=$(($N+1))
    done  
    echo "Novo paired high"
    bash prep_IBEDs_pipeline.sh "${1}" "${2}" "${3}" "${4}" ${5} ${6} ${7} ${8} ${9} ${10} ${11}
    Rscript initial_reads_IBEDs_pipeline.R "Values_run_total_reads_bf_process.txt" ${4}/"Clean_$DATE-$N" --quiet 2>&1 >/dev/null
    echo "A plot containing the initial number of reads before process_radtags can be found in the following directoty ${4}/"Clean_$DATE-$N""
    python ustacks_IBEDs_pipeline.py ${3} ${4} "Clean_$DATE-$N" ${13} ${9} ${10} 
    #python ustacks.py "${3}" "${4}" "Clean_$DATE-$N" "paired" 
    bash count_ustacks_values_IBEDs_pipeline.sh "${4}/Clean_$DATE-$N" ${3}
    Rscript ustacks_values_IBEDs_pipeline.R "Final_ustack_Values.txt" ${4}/"Clean_$DATE-$N" --quiet 2>&1 >/dev/null
    cstacks -o ${4}/"Clean_$DATE-$N" -s ${4}/"Clean_$DATE-$N"/${14} -s ${4}/"Clean_$DATE-$N"/${15}  -n ${9} -p 15 2>  ${4}/"Clean_$DATE-$N"/cstacks.log
    python sstacks_IBEDs_pipeline.py ${3} ${4} "Clean_$DATE-$N" ${13}  
    bash count_sstacks_values_IBEDs_pipeline.sh "${4}/Clean_$DATE-$N" ${3}
    Rscript sstacks_values_IBEDs_pipeline.R "Final_sstack_Values.txt" ${4}/"Clean_$DATE-$N" --quiet 2>&1 >/dev/null
    python tsv2bam_IBEDs_pipeline.py ${3} ${4} "Clean_$DATE-$N"
 
fi
#If 12=false, single end data
if [ "$#" -eq 15 ]; then
    DATE=$(date +"%d%m%Y")
    N=1

    # Increment $N as long as a directory with that name exists                           
    while [[ -d "${3}/Clean_$DATE-$N" ]] ; do
        N=$(($N+1))
    done
    echo "novo single high"
    bash prep_IBEDs_pipeline.sh ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10}
    #python ustacks.py "${2}" "${3}" "Clean_$DATE-$N" "single"
    #while true;do echo -n .;sleep 1;done &
#python ustacks.py ${2} ${3} "Clean_$DATE-$N" ${12} &>/dev/null &
# or do something else here
#kill $!; trap 'kill $!' SIGTERM
#echo done
    Rscript initial_reads_IBEDs_pipeline.R "Values_run_total_reads_bf_process.txt" ${3}/"Clean_$DATE-$N" --quiet 2>&1 >/dev/null
    echo "A plot containing the initial number of reads before process_radtags can be found in the following directoty ${3}/"Clean_$DATE-$N"" 
    python ustacks_IBEDs_pipeline.py ${2} ${3} "Clean_$DATE-$N" ${12} ${8} ${9}  &>/dev/null &
    PID=$!
    i=1
    sp="/-\|"
    echo -n ' '
    while [ -d /proc/$PID ]
        do
            #LS
	    # printf "-"
            printf "\b${sp:i++%${#sp}:1}"
#\b${sp:i++%${#sp}:1}"
        done
    echo "ustacks is done"
    bash count_ustacks_values_IBEDs_pipeline.sh "${3}/Clean_$DATE-$N" ${2}  
    Rscript ustacks_values_IBEDs_pipeline.R "Final_ustack_Values.txt" ${3}/"Clean_$DATE-$N" --quiet 2>&1 >/dev/null
    cstacks -o ${3}/"Clean_$DATE-$N" -s ${3}/"Clean_$DATE-$N"/${13} -s ${3}/"Clean_$DATE-$N"/${14}  -n ${8} -p 15 2>  ${3}/"Clean_$DATE-$N"/cstacks.log &
        PID=$!
    i=1
    sp="/-\|"
    echo -n ' '
    while [ -d /proc/$PID ]
        do
            #LS
            # printf "-"
            printf "\b${sp:i++%${#sp}:1}"
#\b${sp:i++%${#sp}:1}"
        done
    echo "cstacks is done"
    python sstacks_IBEDs_pipeline.py ${2} ${3} "Clean_$DATE-$N" ${12} &>/dev/null &
    PID=$!
    i=1
    sp="/-\|"
    echo -n ' '
    while [ -d /proc/$PID ]
        do
            #LS
            # printf "-"
            printf "\b${sp:i++%${#sp}:1}"
#\b${sp:i++%${#sp}:1}"
        done
    echo "sstacks is done"
    bash count_sstacks_values_IBEDs_pipeline.sh "${3}/Clean_$DATE-$N" ${2}
    Rscript sstacks_values_IBEDs_pipeline.R "Final_sstack_Values.txt" ${3}/"Clean_$DATE-$N" --quiet 2>&1 >/dev/null
    python tsv2bam_IBEDs_pipeline.py ${2} ${3} "Clean_$DATE-$N" &>/dev/null &
    PID=$!
    i=1
    sp="/-\|"
    echo -n ' '
    while [ -d /proc/$PID ]
        do
            #LS
            # printf "-"
            printf "\b${sp:i++%${#sp}:1}"
#\b${sp:i++%${#sp}:1}"
        done
    echo "tsv2bam is done"
    gstacks -P  "${3}/Clean_$DATE-$N" -M ${3}/Popmap_4_dec.txt -t 5 &>/dev/null &
        PID=$!
    i=1
    sp="/-\|"
    echo -n ' '
    while [ -d /proc/$PID ]
        do
            #LS
            # printf "-"
            printf "\b${sp:i++%${#sp}:1}"
#\b${sp:i++%${#sp}:1}"
        done
    echo "gstacks is done"
    populations -P "${3}/Clean_$DATE-$N" --popmap ${3}/Popmap_4_dec.txt --genepop --vcf -t 5 &>/dev/null &
           PID=$!
    i=1
    sp="/-\|"
    echo -n ' '
    while [ -d /proc/$PID ]
        do
            #LS
            # printf "-"
            printf "\b${sp:i++%${#sp}:1}"
#\b${sp:i++%${#sp}:1}"
        done
    echo "Populations is done"
 
fi

sleep 20
