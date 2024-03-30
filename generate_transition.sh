#!/bin/bash

idx="$1"
transition_type="$2"
directory_path="$3"

if (( idx <= 0 )); then
    echo "Invalid idx: must be a non-zero positive integer."
    exit 1
fi

if [[ ! $transition_type =~ ^[12]$ ]]; then
    echo "Invalid transition_type: must be 1 or 2."
    exit 1
fi

First_file=$(find "$directory_path" -type f -name LQ_Long*.nhml)
Second_file=$(find "$directory_path" -type f -name HQ_Short*.nhml)
Third_file=$(find "$directory_path" -type f -name HQ_Long*.nhml)

if [[ $transition_type == 2 ]]; then
    First_file=$(find "$directory_path" -type f -name HQ_Long*.nhml)
    Second_file=$(find "$directory_path" -type f -name LQ_Short*.nhml)
    Third_file=$(find "$directory_path" -type f -name LQ_Long*.nhml)
fi

echo "Proccessing Files:"
echo "$First_file" 
echo "$Second_file"
echo "$Third_file"

rm "$directory_path/first.nhml" "$directory_path/second.nhml" "$directory_path/third.nhml" "$directory_path/playlist.txt" "$directory_path/transition.log"

line_with_idx=$(grep -n "number=\"$idx\"" "$Second_file")

if [[ $line_with_idx ]]; then
    line_with_idx_num=$(echo "$line_with_idx" | cut -d: -f1)
    sap_line=$(tail -n +$line_with_idx_num "$Second_file" | grep "SAPType=\"2\"" | head -n 1)
    if [[ $sap_line ]]; then
        N=$(echo "$sap_line" | grep -oP 'number="\K[^"]+')

        echo $sap_line
        echo "Found N=$N"


        # if [[ $N == $idx ]]; then
        #     # No issues here
        # fi

        # Create "first.nhml"
        echo "Creating first.nhml"
        line_with_N_in_first_file=$(grep -n "number=\"$N\"" "$First_file")
        line_with_N_in_first_file_num=$(echo "$line_with_N_in_first_file" | cut -d: -f1)

        echo "from line 0 to line $line_with_N_in_first_file_num and add last line"
        
        sed -n "1,$((line_with_N_in_first_file_num - 1))p;$((line_with_N_in_first_file_num))q" "$First_file" > "$directory_path/first.nhml"
        tail -n 1 "$First_file" >> "$directory_path/first.nhml"

        echo "first.nhml" >> "$directory_path/playlist.txt"
        echo "Done with first part"
        
        echo "${First_file%.nhml}.log" 1 $((line_with_N_in_first_file_num - 1)) > $directory_path/transition.log

        echo `tail -n +$((line_with_N_in_first_file_num +1)) "$First_file" | grep "SAPType=\"2\"" | head -n 1`
        sap_line_M=$(tail -n +${line_with_N_in_first_file_num} "$First_file" | grep "SAPType=\"2\"" | head -n +1)
        M=$(echo "$sap_line_M" | grep -oP 'number="\K[^"]+')

        echo "Found M=$M"
        
        if [[ $N != $M ]]; then
            # Create "second.nhml"
            echo "Creating second.nhml"

            nhnt_start=$(grep -n "NHNTSample" "$Second_file" | head -n 1 | cut -d: -f1)
            if [[ $nhnt_start ]]; then
                line_with_N_in_second_file=$(grep -n "number=\"$N\"" "$Second_file")
                line_with_N_in_second_file_num=$(echo "$line_with_N_in_second_file" | cut -d: -f1)
                line_with_M_in_second_file=$(grep -n "number=\"$M\"" "$Second_file")
                line_with_M_in_second_file_num=$(echo "$line_with_M_in_second_file" | cut -d: -f1)

                echo "from line 0 to $((nhnt_start - 1)) then from line $line_with_N_in_second_file_num to line $line_with_M_in_second_file_num and add last line"


                sed -n "1,$((nhnt_start - 1))p;$((nhnt_start))q" "$Second_file" >> "$directory_path/second.nhml"
                sed -n "$line_with_N_in_second_file_num,$((line_with_M_in_second_file_num -1))p;$((line_with_M_in_second_file_num))q" "$Second_file" >> "$directory_path/second.nhml"
                tail -n1 "$Second_file" >> "$directory_path/second.nhml"

                echo "second.nhml" >> "$directory_path/playlist.txt"
                echo "Done with second part"

                echo "${Second_file%.nhml}.log" $line_with_N_in_second_file_num $((line_with_M_in_second_file_num -1)) >> $directory_path/transition.log
            fi
        fi
        echo "Creating third.nhml" 
        nhnt_start=$(grep -n "NHNTSample" "$Third_file" | head -n 1 | cut -d: -f1)
        if [[ $nhnt_start ]]; then
            # Create "third.nhml"
            line_with_M_in_third_file=$(grep -n "number=\"$M\"" "$Third_file")
            line_with_M_in_third_file_num=$(echo "$line_with_M_in_third_file" | cut -d: -f1)

            echo "from line 0 to $((nhnt_start - 1)) then from line $line_with_M_in_third_file_num till last line"

            sed -n "1,$((nhnt_start - 1))p;$((nhnt_start))q" "$Third_file" >> "$directory_path/third.nhml"
            tail -n +$line_with_M_in_third_file_num "$Third_file" >> "$directory_path/third.nhml"
            
            echo "third.nhml" >> "$directory_path/playlist.txt"
            echo "Done with third part"

            total_lines=$(wc -l < $Third_file)

            echo "${Third_file%.nhml}.log" $line_with_M_in_third_file_num $((total_lines - 1)) >> $directory_path/transition.log
            
            cat $directory_path/transition.log
        fi
    fi
fi

