#!/bin/bash



DBMS_DIR="dbms"
# CURRENT_DB=""

# Function to replace spaces with underscores in the database name
input_checker() {
    echo "$1" | tr ' ' '_'
}

# Global variables
tableName=""
filePath=""

# Function to check if a string is a valid database name
is_valid_db_name() {
    db_name=$1
     
     # Check if the input is empty
    if [[ -z "$db_name" ]]; then
        echo "Error: Database name cannot be empty. Please enter a valid name."
        return 1
    fi

    # Check if it's a reserved keyword
    if [[ "$db_name" =~ ^(create|list|drop|connect|from|select|update|delete)$ ]]; then
        echo "Warning: '$db_name' is a reserved keyword. Please choose a different name."
        return 1
    fi

    # Check if it starts with a number
    if [[ "$db_name" =~ ^[0-9] ]]; then
        echo "Warning: Database name cannot start with a number."
        return 1
    fi

    # Check for spaces
    if [[ "$db_name" =~ \  ]]; then
        echo "Warning: Spaces in the database name will be replaced with underscores."
    fi
    

    return 0
}

# Function to create a database
create_database() {
    read -p "Enter the name for the new database: " db_name
    validDB_name=$(input_checker "$db_name")

    if is_valid_db_name "$validDB_name"; then
        if [ -d "$DBMS_DIR/$validDB_name" ]; then
            echo "Warning: Database '$validDB_name' already exists."
        else
            mkdir "$DBMS_DIR/$validDB_name"
            echo "Database '$validDB_name' was created successfully."
        fi
    else
        echo "Warning: Invalid database name. Please try again."
    fi
}

# Function to list only database directories
list_databases() {
    local dbms_dir="dbms"
    echo "List of databases:"
    for dir in "$dbms_dir"/*/; do
        if [ -d "$dir" ]; then
            echo "${dir#$dbms_dir}"
        fi
    done
    
}

# Function to drop a database
drop_database() {
    while true; do
        
        read -p "Enter the name of the database you want to remove: " db_name

        
        if [[ -z "$db_name" || ! "$db_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
            echo "Invalid database name. Please enter a valid name without spaces or special characters."

            
            read -p "press any button to try agian and 'n' to go back to main menu: " try_again
            if [ "$try_again" == "n" ]; then
                break
            else
                continue
            fi
        fi

        
        validDB_name=$(input_checker "$db_name")

        
        if [ -d "$DBMS_DIR/$validDB_name" ]; then
            
            read -p "Are you sure you want to remove database '$validDB_name'? (y/n): " confirm
            if [ "$confirm" == "y" ]; then
                
                rm -r "$DBMS_DIR/$validDB_name"
                echo "Database '$validDB_name' removed successfully."
                break
            else
                echo "Removal canceled. Database '$validDB_name' not removed."
                break
            fi
        else
            
            echo "Warning: Database '$db_name' not found. Please try again."
        fi
    done
}
# Function to Disconnecting
disconnecting() {
    echo "Disconnecting from $validDB_name, Goodbye"
    cd ../..
    break
}

# Function to connect to a database and contain all the db features 
connect_to_database() {
    read -p "Enter the name of the database you want to connect to: " db_name
    validDB_name=$(input_checker "$db_name")

    if [ -d "$DBMS_DIR/$validDB_name" ]; then
        cd "$DBMS_DIR/$validDB_name"
        echo "Connected to database '$validDB_name'."
        # here is the start of our dbms mean function as we are actually inside the database directory

        # dbms mean menu
        while true; do
            echo -e "you are now inside $validDB_name database please select any number from 1 to 7 "
            echo "1. Create Table"
            echo "2. List All Tables"
            echo "3. Drop Table"
            echo "4. SELECT"
            echo "5. INSERT"
            echo "6. UPDATE"  
            echo "7. delete from table"
            echo "8. Disconnect from database"

            read -p "Enter your choice 1-7: " dbms_mean_menu_choice
            
            case $dbms_mean_menu_choice in
                1) getValidTableName ;;
                 2)  viewAllTables;;
                  3) dropTable  ;;
                 4) big_select ;;
                  5) insert_data ;;
                6) big_update ;;
                7) big_delete ;;
               8) disconnecting ;;
                *) echo "Invalid choice, Please enter a number between 1 and 7." ;;
            esac
        done

        # end of our dbms function as we will disconnect from the database
    else
        echo "Warning: Database '$validDB_name' not found."
    fi
}
#########################################################
############# Function to create a table ##########
getValidTableName() {
    while true; do
        read -p "Enter the name for the new table: " tableName

        if [ -z "$tableName" ]; then
            echo "Table name cannot be empty. Try again."
            continue
        fi

       
        tableName="${tableName// /_}"

        if [[ ! "$tableName" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            echo "Invalid table name. Try again."
            continue
        fi

        filePath="./${tableName}"
        metadataFile="./.${tableName}"

        if [ -e "$filePath" ] || [ -e "$metadataFile" ]; then
            echo "Table '$tableName' or metadata file already exists. Choose a different name. Try again."
            continue
        fi

        while true; do
            read -p "please note that the PK will be the first column you insert ,Enter the number of columns for the table: " numColumns

            if [ -z "$numColumns" ]; then
                echo "Number of columns cannot be empty. Please enter a positive integer. Try again."
                continue
            elif ! [[ "$numColumns" =~ ^[1-9][0-9]*$ ]]; then
                echo "Invalid number of columns. Please enter a positive integer. Try again."
                continue
            fi
            break
        done

        touch "$metadataFile"

        if [ "$numColumns" -gt 0 ]; then
            touch "$filePath"
            echo "Table '$tableName' created successfully at $filePath"
            break
        else
            echo "Table cannot be created without columns. Please enter a positive number of columns."
        fi
    done

    pkName=""
    for ((i = 1; i <= numColumns; i++)); do
        while true; do
            read -p "Enter the name for column $i: " colName
 colName="${colName// /_}"

            if [ "$colName" == "ID" ]; then
                echo "ID is reserved. Please choose a different column name."
                continue
            elif [ -z "$colName" ]; then
                echo "Column name cannot be empty. Try again."
                continue
            elif ! [[ "$colName" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                echo "Invalid column name. Please enter a valid name."
                continue
            else
                break
            fi
        done

        while true; do
            read -p "Enter the data type for column $colName (int/string): " colType

            if [ "$colType" != "int" ] && [ "$colType" != "string" ]; then
                echo "Invalid data type. Please enter 'int' or 'string'."
                continue
            else
                break
            fi
        done

        if [ -z "$pkName" ]; then
            pkName=$colName
            echo "Primary key is $pkName (default for the first column)"
            echo "$colName:$colType:pk" >> "$metadataFile"
        else
            echo "$colName:$colType" >> "$metadataFile"
        fi
    done

    echo "Table Created!!"
}

#########################################################
############# Function to insert data ##########
insert_data() {
while true; do
read -p "Enter table name: " tableName

        filePath="./${tableName}"
        metadataFile="./.${tableName}"

        if [[ -z "$tableName" || ! "$tableName" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            echo "Invalid table name. Table name must start with a letter and can only contain letters, numbers, and underscores. Try again."
            continue
        fi

        if [ -e "$filePath" ]; then
            echo "File found. Please insert data."

            if [ -e "$metadataFile" ]; then
                columns=()
                pkColumn=""
                pkType=""
                while IFS=':' read -r columnName dataType rest; do
                    columns+=("$columnName:$dataType")
                    if [[ "$rest" == "pk" ]]; then
                        pkColumn="$columnName"
                        pkType="$dataType"
                    fi
                done < "$metadataFile"

                if [ -n "$pkColumn" ]; then
                    echo "Primary key column found: $pkColumn"

                    while true; do
                        read -p "Enter data for $pkColumn ($pkType): " idInput

                        if [ "$pkType" == "int" ] && ! [[ "$idInput" =~ ^[0-9]+$ ]]; then
                            echo "Invalid input. Enter a number for $pkColumn."
                        elif [ "$pkType" == "string" ] && grep -q "^$idInput:" "$filePath"; then
                            echo "Duplicate value. Enter a different $pkColumn."
                        elif [ "$pkType" == "int" ] && grep -q "^$idInput:" "$filePath"; then
                            echo "Duplicate value. Enter a different $pkColumn."
                        elif [ -z "$idInput" ] || [[ "$idInput" =~ ^[[:space:]]+$ ]]; then
                            echo "$pkColumn cannot be empty or contain only spaces. Enter a valid value."
                        else
                            break
                        fi
                    done

                  echo -n "$idInput:" >> "$filePath"

for columnInfo in "${columns[@]}"; do
    IFS=':' read -r columnName dataType <<< "$columnInfo"
    if [ "$columnName" != "$pkColumn" ]; then
        echo "Enter data for $columnName ($dataType):"

        read -r inputData

        while [[ -z "$inputData" || "$inputData" =~ ^[[:space:]]+$ ]]; do
            echo "$columnName cannot be empty or contain only spaces. Enter a valid value:"
            read -r inputData
        done

        if [ "$dataType" == "int" ]; then
            until [[ "$inputData" =~ ^[0-9]+$ ]]; do
                echo "Invalid input. Enter a number for $columnName:"
                read -r inputData
            done
        fi

        echo -n "$inputData:" >> "$filePath"
    fi
done


sed -i 's/:$//' "$filePath"

                   

                    echo "" >> "$filePath"  
                    echo "Data inserted successfully into table '$tableName'."
                    break
                else
                    echo "Error: Primary key column not found in metadata for table '$tableName'."
                    echo "Columns in metadata file: ${columns[@]}"
                fi
            else
                echo "Metadata file not found for table '$tableName'."
            fi
        else
            echo "No file found for table '$tableName'."
            while true; do
                read -p "Do you want to enter another table name? (y/n): " answer

                if [ "$answer" == "y" ]; then
                    break
                elif [ "$answer" == "n" ]; then
                    exit 0
                else
                    echo "Invalid input. Please try again."
                fi
            done
        fi
    done
}


#########################################################
############# Function to list table ##########
function viewAllTables {
    echo "Tables in '$validDB_name':"

    ls -1
}
#########################################################
############# Function to drop table ##########

function validateTableName {
    local tableName="$1"

    if [ -z "$tableName" ] || [[ ! "$tableName" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Invalid table name. Please Try Again."
        return 1
    fi

    return 0
}

function dropTable {
    while true; do
        read -p "Enter the name of the table you want to drop: " dropTableName

        if ! validateTableName "$dropTableName"; then
            continue
        fi

        dropFilePath="./${dropTableName}"
        metadataFilePath="./.${dropTableName}"

        if [ -e "$dropFilePath" ]; then
            while true; do
                read -p "Are you sure you want to drop table '$dropTableName'? (y/n): " dropConfirmation

                case $dropConfirmation in
                    [Yy]*)
                        rm "$dropFilePath"
                        echo "Table '$dropTableName' dropped successfully."

                        if [ -e "$metadataFilePath" ]; then
                            rm "$metadataFilePath"
                            echo "Metadata file for '$dropTableName' dropped as well."
                        else
                            echo "Metadata file for '$dropTableName' not found."
                        fi

                        return
                        ;;
                    [Nn]*)
                        echo "Table '$dropTableName' not dropped."
                        return
                        ;;
                    *)
                        echo "Invalid input. Please enter 'y' or 'n'."
                        ;;
                esac
            done
        else
            echo "Table '$dropTableName' not found."
        fi
    done
}
##############################################**************
###########################################################################################################################################

#start for thr select , delete.and update*****************

# Function to show columns from metadata file
function show_columns() {
    local tableName=$1
    local metadataFile=".$tableName"
    
    if [ -f "$metadataFile" ]; then
        awk -F ':' '{print NR ":" $1}' "$metadataFile" | tr -d ' ' 
    else
        echo "Metadata file for table $tableName does not exist."
        return 1
    fi
}

# Function to check if the table exists
function table_exists() {
    local tableName=$1
    local dataFile="$tableName"
    if [ -f "$dataFile" ]; then
        return 0
    else
        echo "Table $tableName does not exist."
        return 1
    fi
}
function big_select() {


function organize_result() {
    local tableName=$1
    local result=$2
    local numColumns=$(awk -F ':' 'NR==1 {print NF}' "$tableName")
    
   
    awk -F ':' -v numCols="$numColumns" -v result="$result" 'BEGIN {
        split(result, rows, "\n")
        for (i in rows) {
            split(rows[i], values, ":")
            for (j = 1; j <= numCols; j++) {
                printf "%s", values[j]
                if (j < numCols) printf ""
            }
            printf "\n"
        }
    }' <(echo "$tableName") | sed '/^$/d' | sort -n -t':' -k1,1
}

function execute_select() {
    local tableName=$1
    local selectChoice=$2

    case $selectChoice in
        1)
            awk -F '|' '{print $0}' "$tableName" | sed '/^$/d'
            ;;
        
         2)
            echo "Available columns in table $tableName:"
            show_columns "$tableName"
            
            
            while true; do
                read -p "Enter column numbers to select (e.g., 1,2,3): " userEnteredColumns
                
                
                if [[ $userEnteredColumns =~ ^[0-9,]+$ ]]; then
                    
                    local numColumns=$(awk -F ':' 'NR==1 {print NF}' ".$tableName")
                    local validInput=true

                    
                    IFS=',' read -ra columnNumbers <<< "$userEnteredColumns"
                    for colNum in "${columnNumbers[@]}"; do
                        if ! ((colNum > 0 && colNum <= numColumns)); then
                            echo "Invalid column number: $colNum. Please enter valid column numbers."
                            validInput=false
                            break
                        fi
                    done

                    if [ "$validInput" = true ]; then
                        break
                    fi
                else
                    echo "Invalid input. Please enter valid numbers separated by commas."
                fi
            done
            
            
            result=$(awk -F ':' -v cols="$userEnteredColumns" 'BEGIN {split(cols, arr, ",")} {for (i in arr) printf "%s ", $arr[i]; printf "\n"}' "$tableName" | sort -n -t':' -k1,1)
            organize_result "$tableName" "$result"        
            ;;

        3)
           
    while true; do
        echo "Available columns in table $tableName:"
        show_columns "$tableName"

        
        while true; do
            read -p "Enter column number to filter by: " columnNumberOption3

            
            if [[ $columnNumberOption3 =~ ^[0-9]+$ ]]; then
                
                local totalColumns=$(awk -F ':' 'NR==1 {print NF}' ".$tableName")
                if ((columnNumberOption3 > 0 && columnNumberOption3 <= totalColumns)); then
                    break
                else
                    echo "Invalid column number. Please enter a valid column number between 1 and $totalColumns."
                fi
            else
                echo "Invalid input. Please enter a valid number."
            fi
        done

        read -p "Enter value to match: " matchingValue
        matchingRows=$(awk -F ':' -v col="$columnNumberOption3" -v val="$matchingValue" '$col == val {print $0}' "$tableName")

        if [ -z "$matchingRows" ]; then
            echo "No matching rows found for the given value."
            read -p "Do you want to try again? enter y to try again and enter anythig to go back to the previous menu: " tryAgainOption
            if [ "$tryAgainOption" != "y" ]; then
                return
            fi
        else
            echo "$matchingRows"
            break
        fi
    done
    ;;

        4)
            break
            ;;

        *)
            echo "Invalid option. Please enter numbers between 1 and 4."
            ;;
    esac
}

# select loopp start here 
while true; do
    read -p "Please enter the table name (or 'exit' to quit): " tableName

    if [ "$tableName" == "exit" ]; then
        echo "Exiting the program. Bye!"
        break
    fi

    if table_exists "$tableName"; then
        while true; do
            echo "You are now viewing table $tableName"
            echo "1: SELECT * from $tableName"
            echo "2: Select by column"
            echo "3: Select row where column equals a value"
            echo "4: enter other table name or exit"

            
            while true; do
                read -p "Please select an option by entering a number (1-4): " selectOptionForSelect
                if [[ $selectOptionForSelect =~ ^[1-4]$ ]]; then
                    break
                else
                    echo "Invalid input. Please enter a number between 1 and 4."
                fi
            done

            execute_select "$tableName" "$selectOptionForSelect"
        done
    else
        echo "Please make sure to enter a valid table name."
    fi
done
}
#end of the select***
#start of update FUNCATION..............................................................................................................................................
##############################################
function big_update() {
function update_record() {
    local tableName=$1

    
    local totalColumns=$(awk -F ':' 'NR==1 {print NF}' "$tableName")

    echo "Available columns in table $tableName:"
    show_columns "$tableName"

    
    while true; do
        read -p "Enter column number to update: " updateColumnNumber

        
        if [[ $updateColumnNumber =~ ^[0-9]+$ ]] && ((updateColumnNumber > 0 && updateColumnNumber <= totalColumns)); then
            break
        else
            echo "Invalid input. Please enter a valid column number between 1 and $totalColumns."
        fi
    done

    
    local metadataFile=".$tableName"
    local columnName=$(awk -F ':' -v col="$updateColumnNumber" 'NR==col {print $1}' "$metadataFile")
    local dataType=$(awk -F ':' -v col="$updateColumnNumber" 'NR==col {print $2}' "$metadataFile")
    local isPrimaryKey=$(awk -F ':' -v colName="$columnName" '$1 == colName && /pk/ {print $0}' "$metadataFile")

    
    while true; do
        read -p "Enter new value for the selected column: " newValue

        if [ "$dataType" == "string" ]; then
            if [ -n "$newValue" ]; then
                
                local isUnique=$(awk -F ':' -v col="$updateColumnNumber" -v val="$newValue" 'tolower($col) == tolower(val) {print $0}' "$tableName" | wc -l)

                if [ "$isUnique" -eq 0 ]; then
                    break
                else
                    echo "Error: The string value is duplicated. Please enter a different value."
                fi
            else
                echo "Invalid input. Please enter a non-null value for the string column."
            fi
        elif [ "$dataType" == "int" ]; then
            
            if [[ "$newValue" =~ ^[0-9]+$ ]]; then
                break
            else
                echo "Invalid input. Please enter a valid integer."
            fi
        else
            break
        fi
    done

    
    while true; do
        echo "Available columns in table $tableName:"
        show_columns "$tableName"

        read -p "Enter column number to match: " matchColumnNumber

        
        if [[ $matchColumnNumber =~ ^[0-9]+$ ]] && ((matchColumnNumber > 0 && matchColumnNumber <= totalColumns)); then
            break
        else
            echo "Invalid input. Please enter a valid column number between 1 and $totalColumns."
        fi
    done

    
    while true; do
        read -p "Enter value to match: " matchingValue

        
        local isMatchingValue=$(awk -F ':' -v col="$matchColumnNumber" -v val="$matchingValue" '$col == val {print $0}' "$tableName")

        if [ -n "$isMatchingValue" ]; then
            
            local isUnique=$(awk -F ':' -v col="$matchColumnNumber" -v val="$matchingValue" '$col == val {print $0}' "$tableName" | wc -l)

            if [ "$isUnique" -eq 1 ]; then
                break
            else
                echo "Error: The matching value is duplicated. Please enter a different value."
            fi
        else
            echo "Error: The matching value does not exist. Please enter a valid value."
            read -p "Do you want to try again? Enter 'y' to try again, or enter anything else to go back to the previous menu: " tryAgainOption

            if [ "$tryAgainOption" != "y" ]; then
                return
            fi
        fi
    done

    # Update the matching row
    awk -F ':' -v colToUpdate="$updateColumnNumber" -v newVal="$newValue" -v colToMatch="$matchColumnNumber" -v matchVal="$matchingValue" '
        BEGIN { OFS = FS }
        $colToMatch == matchVal { $colToUpdate = newVal }
        { print $0 }
    ' "$tableName" > temp_file && mv temp_file "$tableName"

    echo "Row updated successfully."
}


#********
#********
function update_row() {
    local tableName=$1
    local totalColumns=$(awk -F ':' 'NR==1 {print NF}' "$tableName")
    echo "Available columns in table $tableName:"
    show_columns "$tableName"
    declare -a newValues

    for ((i=1; i<=totalColumns; i++)); do
        local metadataFile=".$tableName"
        local columnName=$(awk -F ':' -v col="$i" 'NR==col {print $1}' "$metadataFile")
        local dataType=$(awk -F ':' -v col="$i" 'NR==col {print $2}' "$metadataFile")

        while true; do
            IFS= read -r -p "Enter new value for column $i ($columnName): " newValue

            if [ "$dataType" == "string" ]; then
                if [ -n "$newValue" ]; then
                    local isDuplicate=$(awk -F ':' -v col="$i" -v val="$newValue" '$col == val {print $0}' "$tableName")
                    if [ -z "$isDuplicate" ]; then
                        newValues[$i]="$newValue"
                        break
                    else
                        echo "Duplicate value for column $i. Please enter a unique value."
                    fi
                else
                    echo "Invalid input. Please enter a non-null value for the string column."
                fi
            elif [ "$dataType" == "int" ]; then
                if [[ "$newValue" =~ ^[0-9]+$ ]]; then
                    newValues[$i]="$newValue"
                    break
                else
                    echo "Invalid input. Please enter a valid integer."
                fi
            else
                newValues[$i]="$newValue"
                break
            fi
        done
    done

    while true; do
        echo "Available columns in table $tableName:"
        show_columns "$tableName"
        IFS= read -r -p "Enter column number to match: " matchColumnNumber

        if [[ $matchColumnNumber =~ ^[0-9]+$ ]] && ((matchColumnNumber > 0 && matchColumnNumber <= totalColumns)); then
            break
        else
            echo "Invalid input. Please enter a valid column number between 1 and $totalColumns."
        fi
    done

    while true; do
        IFS= read -r -p "Enter value to match: " matchingValue

        local isMatchingValue=$(awk -F ':' -v col="$matchColumnNumber" -v val="$matchingValue" '$col == val {print $0}' "$tableName")

        if [ -n "$isMatchingValue" ]; then
            local isUnique=$(awk -F ':' -v col="$matchColumnNumber" -v val="$matchingValue" '$col == val {print $0}' "$tableName" | wc -l)

            if [ "$isUnique" -eq 1 ]; then
                break
            else
                echo "Error: The matching value is duplicated. Please enter a different value."
            fi
        else
            echo "Error: The matching value does not exist. Please enter a valid value."

            read -p "Do you want to try again? Enter 'y' to try again, or enter anything else to go back to the previous menu: " tryAgainOption

            if [ "$tryAgainOption" != "y" ]; then
                return
            fi
        fi
    done
#l print fincationnnns
 
    joinedValues=$(IFS='|'; echo "${newValues[*]}")

   
    joinedValuesWithoutSpaces=$(echo "$joinedValues" | sed 's/^\( *\)/###SPACE###\1/' | sed 's/\( *\)$$/\1###SPACE###/')

    awk -F ':' -v newVals="$joinedValuesWithoutSpaces" -v colToMatch="$matchColumnNumber" -v matchVal="$matchingValue" '
    BEGIN { OFS = FS; }
    $colToMatch == matchVal { 
        gsub(/###SPACE###/, " ", newVals); 
        split(newVals, arr, "|")
        for (i=1; i<=NF; i++) {
            $i = arr[i]
        }
        sub(/^ /, "", $0); #to remove spacesss
    }
    { print $0 }
    ' "$tableName" > temp_file && mv temp_file "$tableName"

    echo "Row updated successfully."
}


# end of update row *******


# Function to execute SELECT query
function execute_select_update() {
    local tableName=$1
    local selectChoiceUPDATE=$2

    case $selectChoiceUPDATE in
        1)
            update_record "$tableName"
            ;;
        2)
            update_row "$tableName"
            ;;
            
            3)
          
            break
            ;;
        *)
            echo "Invalid option. Please enter numbers between 1 and 2."
            ;;
    esac
}

# Main program loop
while true; do
    read -p "Please enter the table name (or 'exit' to quit): " tableName

    if [ "$tableName" == "exit" ]; then
        echo "Exiting the program. Bye!"
        break
    fi

    if table_exists "$tableName"; then
        while true; do
            echo "You are now viewing table $tableName"
            
            echo "1: Update a single record"
            echo "2: Update the entire row"
             echo "3: enter other table name or exit "
            

            
            while true; do
                read -p "Please select an option by entering a number (1:3 ): " selectOptionUPDATE
                if [[ $selectOptionUPDATE =~ ^[123]$ ]]; then
                    break
                else
                    echo "Invalid input. Please enter 1 or 2 or 3."
                fi
            done

            execute_select_update "$tableName" "$selectOptionUPDATE"
        done
    else
        echo "Please make sure to enter a valid name."
    fi
done
}
#end of updateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee funcatonnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn


#START OF DELETE FUNCATION..............................................................................................................................................
function big_delete() {
function deleteFUNCTION() {
    local tableName=$1
    local deleteChoice=$2

    case $deleteChoice in
        1)
            echo "Deleting all data from table $tableName"
            > "$tableName"
            ;;
    
       
          2)
             echo "Available columns in table $tableName:"
            show_columns "$tableName"
            
            
            while true; do
                read -p "Enter column number to filter by: " columnNumberOption3
                
                
                if [[ $columnNumberOption3 =~ ^[0-9]+$ ]]; then
                    
                    local totalColumns=$(awk -F ':' 'NR==1 {print NF}' ".$tableName")
                    if ((columnNumberOption3 > 0 && columnNumberOption3 <= totalColumns)); then
                        break
                    else
                        echo "Invalid column number. Please enter a valid column number between 1 and $totalColumns."
                    fi
                else
                    echo "Invalid input. Please enter a valid number."
                fi
            done

            
            while true; do
                read -p "Enter value to match: " matchingValue
                
                
                if awk -F ':' -v col="$columnNumberOption3" -v val="$matchingValue" '$col == val {exit 1}' "$tableName"; then
                    echo "The matching value does not exist."
                    read -p "enter 'yes' return to the previous menu or press anything to try another value: " returnOption
                    if [ "$returnOption" == "yes" ]; then
                        return
                    fi
                else
                    
                    if [ $(awk -F ':' -v col="$columnNumberOption3" -v val="$matchingValue" 'BEGIN {count=0} $col == val {count++} END {print count}' "$tableName") -gt 1 ]; then
                        read -p "The matching value is duplicated. Are you sure you want to delete it? (y)or press anything to try another value " confirmation
                        if [[ $confirmation == 'y' || $confirmation == 'Y' ]]; then
                            break
                        fi
                    else
                        break
                    fi
                fi
            done

            
            awk -F ':' -v col="$columnNumberOption3" -v val="$matchingValue" '$col != val {print $0}' "$tableName" > temp && mv temp "$tableName"
            echo "row deleted succesfully"
            ;;
        3)
            break
            ;;
        *)
            echo "Invalid option. Please enter numbers between 1 and 4."
            ;;
    esac
}




# THE DELETE DML MAIN SECTION ..........................................................
while true; do
    read -p "Please enter the table name (or 'exit' to quit): " tableName

    if [ "$tableName" == "exit" ]; then
        echo "Exiting the program. Bye!"
        break
    fi

    if table_exists "$tableName"; then
        while true; do
            echo "You are now viewing table $tableName"
            echo "1: DELETE all data from $tableName"
          
            echo "2: Delete row where column equals a value"
            echo "3: enter another table name or quit"

            
            while true; do
                read -p "Please select an option by entering a number (1-4): " deleteOption
                if [[ $deleteOption =~ ^[1-4]$ ]]; then
                    break
                else
                    echo "Invalid input. Please enter a number between 1 and 4."
                fi
            done

            deleteFUNCTION "$tableName" "$deleteOption"
        done
    else
        echo "Table $tableName does not exist. Please enter a valid table name."
    fi
done
}
#END OF THE DELETE DML MAIN SECTION ..........................................................


#END OF DELETE FUNCATION..............................................................................................................................................




# Check if DBMS directory exists, create it if not
if [ ! -d "$DBMS_DIR" ]; then
    mkdir "$DBMS_DIR"
fi

# Main menu
while true; do
    echo -e "\nDBMS Menu:"
    echo "1. Create Database"
    echo "2. List All Databases"
    echo "3. Drop Database"
    echo "4. Connect to Database"
    echo "5. Exit"

    read -p "Enter your choice 1-5: " choice

    case $choice in
        1) create_database ;;
        2) list_databases ;;
        3) drop_database ;;
        4) connect_to_database ;;
        5) echo "Exiting DBMS. Goodbye"; exit ;;
        *) echo "Invalid choice, Please enter a number between 1 and 5." ;;
    esac
done
