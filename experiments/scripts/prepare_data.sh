#!/usr/bin/env bash

# 需要对after_join.csv 做出注释.
NII_LOC_PATH=./data/csv_files/nii_loc_df.csv
RIB_TYPE_LOCATION_PATH=./data/csv_files/rib_type_location.xls
RIB_DF_CACHE_DIR=./data/
JOIN_LABEL_PATH=./data/csv_files/join_label.csv

Voc2007_folder=./data/voc2007
Voc2007_Annotations_folder=./data/voc2007/Annotations
Voc2007_ImageSets_folder=./data/voc2007/ImageSets
Voc2007_JPEGSImages_folder=./data/voc2007/JPEGSImages

function re_mkdir_folder(){
    rm -rf $1
    mkdir -p $1
    echo "re mkdir $1"
}

re_mkdir_folder  ${Voc2007_Annotations_folder}
re_mkdir_folder  ${Voc2007_ImageSets_folder}
re_mkdir_folder  ${Voc2007_JPEGSImages_folder}

# join all the rib, bounding box, excel_df
python3 ./preprocessing/prepare_data/join_xls_nii_rib.py  --ribs_df_cache_folder  ${RIB_DF_CACHE_DIR} \
                                                          --nii_loc_df_path  ${NII_LOC_PATH}  \
                                                          --rib_type_location_path  ${RIB_TYPE_LOCATION_PATH}  \
                                                          --data_join_label_path  ${JOIN_LABEL_PATH}

# separate voc2007 part from join part
echo "######## split ribs_dataSet into independent picture and save offset shift ########"
python3  ./preprocessing/prepare_data/voc2007/to_ribs_dataset_voc2007.py  --in_folder_path  ${RIB_DF_CACHE_DIR}  \
                                         --output_independent_rib_folder  ${Voc2007_JPEGSImages_folder}  \
                                         --output_format  ".jpg"

echo "######## generate voc2007 format: annotations ########"
python3  ./preprocessing/prepare_data/voc2007/generate_xml_voc2007.py  \
                                    --label_loc_type_info_path  ${JOIN_LABEL_PATH}  \
                                    --voc2007_Annotations_folder  ${Voc2007_Annotations_folder}

echo "######## generate voc2007 format: imageSets ########"
python3  ./preprocessing/prepare_data/voc2007/write_imagesets_voc2007.py  \
                                       --voc2007_Annotations_folder  ${Voc2007_Annotations_folder}  \
                                       --voc2007_ImageSets_folder  ${Voc2007_ImageSets_folder}