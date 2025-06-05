cwlVersion: v1.2
class: Workflow

inputs:
  sds_dicom:
    type: Directory
  sds_seg_model_lung:
    type: Directory
  sds_seg_model_skin:
    type: Directory
  sds_pca_model:
    type: Directory
outputs:
  sds_clinical_report:
    type: Directory
    outputSource: create_clinical_report/sds_clinical_report

steps:
  # step 1
  create_nifti:
    run:
      class: Operation
      inputs:
        sds_dicom: Directory
      outputs:
        sds_nifti: Directory
    in:
      sds_dicom: sds_dicom
    out: [sds_nifti]

  # step 2
  segment:
    run:
      class: Operation
      inputs:
        sds_nifti: Directory
        sds_seg_model_lung: Directory
        sds_seg_model_skin: Directory
      outputs:
        sds_segmentation: Directory
    in:
      sds_nifti: create_nifti/sds_nifti
      sds_seg_model_lung: sds_seg_model_lung
      sds_seg_model_skin: sds_seg_model_skin
    out: [sds_segmentation]

  # step 3
  create_point_cloud:
    run:
      class: Operation
      inputs:
        sds_segmentation: Directory
      outputs:
        sds_point_cloud: Directory
    in:
      sds_segmentation: segment/sds_segmentation
    out: [sds_point_cloud]

  # step 4
  create_mesh:
    run:
      class: Operation
      inputs:
        sds_point_cloud: Directory
        sds_pca_model: Directory
      outputs:
        sds_mesh: Directory
    in:
      sds_point_cloud: create_point_cloud/sds_point_cloud
      sds_pca_model: sds_pca_model
    out: [sds_mesh]

  # step 5
  locate_tumour:
    run:
      class: Operation
      inputs:
        sds_dicom: Directory
        sds_mesh: Directory
        sds_segmentation: Directory
      outputs:
        sds_tumour_location: Directory
    in:
      sds_dicom: sds_dicom
      sds_mesh: create_mesh/sds_mesh
      sds_segmentation: segment/sds_segmentation
    out: [sds_tumour_location]

  # step 6
  create_clinical_report:
    run:
      class: Operation
      inputs:
        sds_tumour_location: Directory
      outputs:
        sds_clinical_report: Directory
    in:
      sds_tumour_location: locate_tumour/sds_tumour_location
    out: [sds_clinical_report]
