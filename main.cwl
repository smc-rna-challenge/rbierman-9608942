arguments:
- position: 50
  separate: true
  valueFrom: {class: Expression, engine: '#cwl-js-engine', script: "{  \n  // call\
      \ spachete_feeder.py args\n  sample = $job.inputs.dataset_name\n  toy = $job.inputs.ToyIndelIndices_tar.path.split(\"\
      /\").pop()\n  //ex = $job.inputs.HG19exons_tar.path.split(\"/\").pop()\n  args\
      \ = \"--root-dir $(pwd)/SPACHETE --mode hg19 --reg-indel-indices $(pwd)/toyIndelIndices/\
      \ --circref-dir $(pwd)/index\"\n  in_dir = \" --circpipe-dir $(pwd)/\" + sample\n\
      \  out_dir = \" --output-dir $(pwd)/SPACHETE_out \"\n  args = args + in_dir\
      \ + out_dir\n  logs = \" 1> $(pwd)/SPACHETE/logs/spachete_feeder.out 2> $(pwd)/SPACHETE/logs/spachete_feeder.err\"\
      \n  return args + logs\n}"}
- position: 51
  separate: false
  valueFrom: {class: Expression, engine: '#cwl-js-engine', script: "{\n  return \"\
      \ && cp ./SPACHETE_out/**/*.{err,out} ./SPACHETE_out/**/MasterError.txt ./SPACHETE/logs\"\
      \n}"}
baseCommand:
- sh
- prepare_directories.sh
- '&&'
- python
- callknife.py
- {class: Expression, engine: '#cwl-js-engine', script: "{\n  data = \"--dataset=\"\
    \ + $job.inputs.dataset_name\n  style = \"--readidstyle=\" + $job.inputs.read_id_style\n\
    \  return data + \" \" + style\n}"}
- '&&'
- python
- ./SPACHETE/wrappers/spachete_feeder.py
class: CommandLineTool
cwlVersion: sbg:draft-2
dct:creator: {'@id': 'http://orcid.org/0000-0002-7681-6415', 'foaf:mbox': rbierman@synapse.org,
  'foaf:name': rbierman}
description: 'SPACHETE version 04May2017.

  This app contains KNIFE and SPACHETE calls all together - first KNIFE command is
  executed and the output directory obtained in that run is passed to SPACHETE.'
doc: 'SMC-RNA challenge fusion detection submission

  '
hints:
- {class: 'sbg:CPURequirement', value: 36}
- {class: 'sbg:MemRequirement', value: 60000}
- {class: DockerRequirement, dockerImageId: '', dockerPull: 'quay.io/smc-rna-challenge/rbierman-9608942-spachete_bundle:1.0.0'}
- {class: 'sbg:AWSInstanceType', value: c4.8xlarge}
id: https://cgc-api.sbgenomics.com/v2/apps/anaDsbg/spachete-demo-project/spachete-bundle/1/raw/
inputs:
- description: Type infile (NO ASTERISK) in search box. The interface should narrow
    the file list to 43 files. Click in the box to the left of Refresh to select all
    43 files.
  id: '#indices'
  label: Indices
  sbg:stageInput: link
  type:
  - {items: File, type: array}
- description: Name of dataset-NO SPACES- will be used for naming files
  id: '#dataset_name'
  label: Name of data set
  type: [string]
- id: '#ToyIndelIndices_tar'
  sbg:fileTypes: TAR.GZ
  sbg:stageInput: link
  type: [File]
- description: Archived (.tar file) exons directory.
  id: '#HG19exons_tar'
  label: Exons Directory
  sbg:fileTypes: TAR.GZ
  sbg:stageInput: link
  type: [File]
- description: Read sequence. In case of paired-end alignment it is crucial to set
    metadata 'paired-end' field to 1/2.
  id: '#reads'
  label: Read sequence
  sbg:fileTypes: FASTA, FASTQ, FA, FQ, FASTQ.GZ, FQ.GZ, FASTQ.BZ2, FQ.BZ2
  sbg:stageInput: link
  type:
  - {items: File, type: array}
- id: '#read_id_style'
  label: Read ID Style
  type:
  - name: read_id_style
    symbols: [appended, complete]
    type: enum
label: SPACHETE bundle
outputs:
- id: '#log_file'
  label: KNIFE log file
  outputBinding: {glob: log*.txt, 'sbg:inheritMetadataFrom': '#reads'}
  type: ['null', File]
- id: '#spachete_logs'
  label: SPACHETE Logs
  outputBinding: {glob: ./SPACHETE/logs/*, 'sbg:inheritMetadataFrom': '#reads'}
  type:
  - 'null'
  - {items: File, type: array}
- id: '#timed_events'
  label: Timed Events
  outputBinding: {glob: ./SPACHETE_out/**/err_and_out/timed_events.txt, 'sbg:inheritMetadataFrom': '#reads'}
  sbg:fileTypes: TXT
  type: ['null', File]
- id: '#naive_report_appended'
  label: Naive Report Appended
  outputBinding: {glob: ./SPACHETE_out/**/reports/AppendedReports/*_naive_report_Appended.txt,
    'sbg:inheritMetadataFrom': '#reads'}
  sbg:fileTypes: TXT
  type: ['null', File]
- id: '#spork_params'
  label: Spork Params
  outputBinding: {glob: ./SPACHETE_out/**/spork_out/params.txt, 'sbg:inheritMetadataFrom': '#reads'}
  sbg:fileTypes: TXT
  type: ['null', File]
- id: '#novel_junctions'
  label: Novel Junctions
  outputBinding: {glob: ./SPACHETE_out/**/spork_out/novel_junctions.fasta, 'sbg:inheritMetadataFrom': '#reads'}
  sbg:fileTypes: FASTA
  type: ['null', File]
- id: '#spork_timed_events'
  label: Spork Timed Events
  outputBinding: {glob: ./SPACHETE_out/**/spork_out/timed_events.txt, 'sbg:inheritMetadataFrom': '#reads'}
  sbg:fileTypes: TXT
  type: ['null', File]
requirements:
- class: ExpressionEngineRequirement
  id: '#cwl-js-engine'
  requirements:
  - {class: DockerRequirement, dockerPull: rabix/js-engine}
- class: CreateFileRequirement
  fileDef:
  - fileContent: {class: Expression, engine: '#cwl-js-engine', script: "{\n  var exons\
        \ = $job.inputs.HG19exons_tar.path.split(\"/\").pop(0);\n  var toy = $job.inputs.ToyIndelIndices_tar.path.split(\"\
        /\").pop(0);\n    \n  return \"\\\n  #!/bin/bash\\n\\\n  #\\n\\\n  # Script\
        \ for preparing the directory structure\\n\\\n  \\n\\\n  mkdir /KNIFE_MACH\\\
        n\\\n  mkdir index\\n\\\n  mkdir denovo_scripts\\n\\\n  mkdir denovo_scripts/index\\\
        n\\\n  mv infilebt2* index/\\n\\\n  mv infilefastas* index/\\n\\\n  mv infilegtf*\
        \ denovo_scripts/\\n\\\n  mv infilebt1* denovo_scripts/index/\\n\\\n  \\n\\\
        \n  cd index/\\n\\\n  # From all files which have prefix \\\"infilebt2\\\"\
        \ remove that prefix\\n\\\n  for name in infilebt2*; do newname=$(echo \\\"\
        $name\\\" | cut -c10-); mv \\\"$name\\\" \\\"$newname\\\"; done\\n\\\n  \\\
        n\\\n  # From all files which have prefix \\\"infilefastas\\\" remove that\
        \ prefix\\n\\\n  for name in infilefastas*; do newname=$(echo \\\"$name\\\"\
        \ | cut -c13-); mv \\\"$name\\\" \\\"$newname\\\"; done\\n\\\n  \\n\\\n  cd\
        \ -\\n\\\n  cd denovo_scripts/\\n\\\n  # From all files which have prefix\
        \ \\\"infilegtf\\\" remove that prefix\\n\\\n  for name in infilegtf*; do\
        \ newname=$(echo \\\"$name\\\" | cut -c10-); mv \\\"$name\\\" \\\"$newname\\\
        \"; done\\n\\\n  \\n\\\n  cd -\\n\\\n  cd denovo_scripts/index/\\n\\\n  #\
        \ From all files which have prefix \\\"infilebt1\\\" remove that prefix\\\
        n\\\n  for name in infilebt1*; do newname=$(echo \\\"$name\\\" | cut -c10-);\
        \ mv \\\"$name\\\" \\\"$newname\\\"; done\\n\\\n  \\n\\\n  cd -\\n\\\n  mkdir\
        \ HG19exons && tar -xvf \" + exons + \" -C HG19exons --strip-components 1\\\
        n\\\n  mkdir toyIndelIndices && tar -xvf \" + toy + \" -C toyIndelIndices\
        \ --strip-components 1\\n\\\n  \\n\\\n  # Copy SPACHETE dir in current dir\\\
        n\\\n  cp -r /srv/software/SPACHETE/ .\\n\\\n  mkdir ./SPACHETE/logs\\n\\\n\
        \  \\\n  \";\n}"}
    filename: prepare_directories.sh
  - {fileContent: "import re, os, glob, subprocess\nfrom distutils.dir_util import\
      \ copy_tree\nfrom shutil import copyfile\n\nWORK_DIR = os.getcwd()\n#########################################################################\n\
      # PARAMETERS, I.E. INPUTS TO KNIFE CALL; need to add these here\n# NOTE: When\
      \ run via docker, a volume named KNIFE_MACH must be mounted \n# and contain\
      \ all required index, annotation, and reference files. FOR\n# NOW, this script.\
      \ KNIFE_MACH must be located on level above WORK_DIR \n# on the host machine.\n\
      #########################################################################\n\n\
      use_toy_indel = True\n\n# dataset_name CANNOT HAVE ANY SPACES IN IT\nimport\
      \ argparse\nparser = argparse.ArgumentParser()\nparser.add_argument(\"--dataset\"\
      , help=\"name of dataset-NO SPACES- will be used for naming files\")\nparser.add_argument(\"\
      --readidstyle\", help=\"read_id_style MUST BE either complete or appended\"\
      )\nparser.add_argument(\"--resources\", help=\"path to directory containing\
      \ references, annotation, and indices; defaults to /KNIFE_MACH\")\nargs = parser.parse_args()\n\
      if args.dataset:\n    dataset_name = args.dataset\nelse:\n    dataset_name =\
      \ \"noname\"\n\nif args.readidstyle:\n    read_id_style = args.readidstyle\n\
      \    if (read_id_style not in ['complete','appended']):\n        raise ValueError(\"\
      Error: readidstyle must be one of complete or appended\")\nelse:\n    raise\
      \ ValueError(\"Error: readidstyle must be one of complete or appended\")\n\n\
      if args.resources:\n    RESOURCE_DIR = args.resources\nelse:\n    RESOURCE_DIR\
      \ =\"/KNIFE_MACH\"\n    \nmode = \"skipDenovo\"\njunction_overlap =  8\nreport_directory_name\
      \ = \"circReads\"\nntrim = 50\n\n# Not really used, just doing so it mimics\
      \ test Data call\nlogstdout_from_knife = \"logofstdoutfromknife\"\n\n##########################\n\
      ### USAGE\n############################\n\n# sh completeRun.sh read_directory\
      \ read_id_style alignment_parent_directory \n# dataset_name junction_overlap\
      \ mode report_directory_name ntrim denovoCircMode \n# junction_id_suffix 2>&1\
      \ | tee out.log\n# https://github.com/lindaszabo/KNIFE/tree/master/circularRNApipeline_Standalone\n\
      \n#########################################################################\n\
      # End of parameters\n#########################################################################\n\
      \ \n# first have to create directories (if they don't already exist)\n# and\
      \ change file names and mv them to the right directories\n\n# get current working\
      \ dir\n\nlogfile = WORK_DIR + \"/logkmach\" + dataset_name + \".txt\"\n\nwith\
      \ open(logfile, 'w') as ff:\n    ff.write(WORK_DIR)\n    ff.write('\\n\\n\\\
      n')\n\n# main directory to be used when running the knife:\nKNIFE_DIR = \"/srv/software/knife/circularRNApipeline_Standalone\"\
      \n\n# place files in appropriate locations; fix code in future to\n# avoid this\
      \ step\n\nanly_src = (KNIFE_DIR + \"/analysis\")\nanly_dst = (RESOURCE_DIR +\
      \ \"/analysis\")\nanly_dst2 = (WORK_DIR + \"/analysis\")\nif not os.path.exists(anly_dst):\n\
      \        copy_tree(anly_src, anly_dst)\nif not os.path.exists(anly_dst2):\n\
      \        os.symlink(anly_dst, anly_dst2)\n\ncomprun_src = (KNIFE_DIR + \"/completeRun.sh\"\
      )\ncomprun_dst = (RESOURCE_DIR + \"/completeRun.sh\")\ncomprun_dst2 = (WORK_DIR\
      \ + \"/completeRun.sh\")\nif not os.path.exists(comprun_dst):\n        copyfile(comprun_src,\
      \ comprun_dst)\nif not os.path.exists(comprun_dst2):\n        os.symlink(comprun_dst,\
      \ comprun_dst2)\n\nfindcirc_src = (KNIFE_DIR + \"/findCircularRNA.sh\")\nfindcirc_dst\
      \ = (RESOURCE_DIR + \"/findCircularRNA.sh\")\nfindcirc_dst2 = (WORK_DIR + \"\
      /findCircularRNA.sh\")\nif not os.path.exists(findcirc_dst):\n        copyfile(findcirc_src,\
      \ findcirc_dst)\nif not os.path.exists(findcirc_dst2):\n        os.symlink(findcirc_dst,\
      \ findcirc_dst2)\n\nparfq_src = (KNIFE_DIR + \"/ParseFastQ.py\")\nparfq_dst\
      \ = (RESOURCE_DIR  + \"/ParseFastQ.py\")\nparfq_dst2 = (WORK_DIR + \"/ParseFastQ.py\"\
      )\nif not os.path.exists(parfq_dst):\n        copyfile(parfq_src, parfq_dst)\n\
      if not os.path.exists(parfq_dst2):\n        os.symlink(parfq_dst, parfq_dst2)\n\
      \nqstats_src = (KNIFE_DIR + \"/qualityStats\")\nqstats_dst = (RESOURCE_DIR +\
      \ \"/qualityStats\")\nqstats_dst2 = (WORK_DIR + \"/qualityStats\")\nif not os.path.exists(qstats_dst):\n\
      \        copy_tree(qstats_src, qstats_dst)\nif not os.path.exists(qstats_dst2):\n\
      \        os.symlink(qstats_dst, qstats_dst2)\n\ndns_src = (KNIFE_DIR + \"/denovo_scripts\"\
      )\ndns_dst = (RESOURCE_DIR + \"/denovo_scripts\")\ndns_dst2 = (WORK_DIR + \"\
      /denovo_scripts\")\nif not os.path.exists(dns_dst):\n\tcopy_tree(dns_src, dns_dst)\n\
      if not os.path.exists(dns_dst2):\n\tos.symlink(dns_dst, dns_dst2)\n\nsubprocess.call(['chmod',\
      \ '-R', '755', RESOURCE_DIR])\n\n\ntargetdir_list = [WORK_DIR + \"/index\",\
      \ WORK_DIR + \"/denovo_scripts\", WORK_DIR + \"/denovo_scripts/index\"]\n  \
      \  \n# check that all the subdirectories are there, as they should be!\n# these\
      \ should have been made beforehand, and should have appropriate files in them:\n\
      # files starting with infilebt2 and infilefastas should be in /index\n#   and\
      \ the prefixes \"infilebt2\" and \"infilefastas\" should be removed\n# files\
      \ starting with infilegtf should be in /denovo_scripts\n#   and the prefix \"\
      infilegtf\" should be removed\n# files starting with infilebt1 should be in\
      \ /denovo_scripts/index\n#   and the prefix \"infilebt1\" should be removed\n\
      \n    \nthisdir = targetdir_list[0]\nif not os.path.exists(thisdir):\n    raise\
      \ ValueError(\"Error: directory \" + thisdir + \" does not exist.\")\n\nthisdir\
      \ = targetdir_list[1]\nif not os.path.exists(thisdir):\n    raise ValueError(\"\
      Error: directory \" + thisdir + \" does not exist.\")\n\nthisdir = targetdir_list[2]\n\
      if not os.path.exists(thisdir):\n    raise ValueError(\"Error: directory \"\
      \ + thisdir + \" does not exist.\")\n\n    \n# cd into the knife directory;\
      \ should not really be necessary\nos.chdir(WORK_DIR)\n\n#with open(logfile,\
      \ 'a') as ff:\n#    ff.write('\\n\\n\\n')\n#    subprocess.check_call([\"ls\"\
      , \"-R\"], stdout=ff)\n#    ff.write('\\n\\n\\n')\n    \n\n# run test of knife\n\
      # sh completeRun.sh READ_DIRECTORY complete OUTPUT_DIRECTORY testData 8 phred64\
      \ circReads 40 2>&1 | tee out.log\n\ntry:\n    with open(logfile, 'a') as ff:\n\
      \        ff.write('\\n\\n\\n')\n        # changing so as to remove calls to\
      \ perl:\n        subprocess.check_call(\"sh completeRun.sh \" + WORK_DIR + \"\
      \ \" + read_id_style + \" \" + WORK_DIR + \" \" + dataset_name + \" \" + str(junction_overlap)\
      \ + \" \" + mode + \" \" + report_directory_name + \" \" + str(ntrim) + \" 2>&1\
      \ | tee \" + logstdout_from_knife , stdout = ff, shell=True)\n        # original\
      \ test call:\n        # subprocess.check_call(\"sh completeRun.sh \" + WORK_DIR\
      \ + \" complete \" + WORK_DIR + \" testData 8 phred64 circReads 40 2>&1 | tee\
      \ outknifelog.txt\", stdout = ff, shell=True)\nexcept:\n    with open(logfile,\
      \ 'a') as ff:\n        ff.write('Error in running completeRun.sh')", filename: callknife.py}
sbg:appVersion: ['sbg:draft-2']
sbg:cmdPreview: sh prepare_directories.sh && python callknife.py --dataset=datasetname-string-value
  --readidstyle=appended && python ./SPACHETE/wrappers/spachete_feeder.py  --root-dir
  $(pwd)/SPACHETE --mode hg19 --reg-indel-indices $(pwd)/toyIndelIndices/ --circref-dir
  $(pwd)/index --circpipe-dir $(pwd)/datasetname-string-value --output-dir $(pwd)/SPACHETE_out  1>
  $(pwd)/SPACHETE/logs/spachete_feeder.out 2> $(pwd)/SPACHETE/logs/spachete_feeder.err  &&
  cp ./SPACHETE_out/**/*.{err,out} ./SPACHETE_out/**/MasterError.txt ./SPACHETE/logs
sbg:contributors: [anaDsbg]
sbg:createdBy: anaDsbg
sbg:createdOn: 1493979811
sbg:id: anaDsbg/spachete-demo-project/spachete-bundle/1
sbg:image_url: null
sbg:job:
  allocatedResources: {cpu: 36, mem: 60000}
  inputs:
    HG19exons_tar:
      class: File
      path: /path/to/HG19exons_tar.ext
      secondaryFiles: []
      size: 0
    ToyIndelIndices_tar:
      class: File
      path: /path/to/ToyIndelIndices_tar.ext
      secondaryFiles: []
      size: 0
    dataset_name: datasetname-string-value
    indices:
    - class: File
      path: /path/to/inputarray-1.ext
      secondaryFiles: []
      size: 0
    - class: File
      path: /path/to/inputarray-2.ext
      secondaryFiles: []
      size: 0
    read_id_style: appended
    reads:
    - class: File
      path: /path/to/reads-1.ext
      secondaryFiles: []
      size: 0
    - class: File
      path: /path/to/reads-2.ext
      secondaryFiles: []
      size: 0
sbg:latestRevision: 1
sbg:modifiedBy: anaDsbg
sbg:modifiedOn: 1493980096
sbg:project: anaDsbg/spachete-demo-project
sbg:projectName: SPACHETE Demo Project
sbg:revision: 1
sbg:revisionNotes: Version 04May2017 - init.
sbg:revisionsInfo:
- {'sbg:modifiedBy': anaDsbg, 'sbg:modifiedOn': 1493979811, 'sbg:revision': 0, 'sbg:revisionNotes': null}
- {'sbg:modifiedBy': anaDsbg, 'sbg:modifiedOn': 1493980096, 'sbg:revision': 1, 'sbg:revisionNotes': Version
    04May2017 - init.}
sbg:sbgMaintained: false
sbg:toolkitVersion: 04May2017
sbg:validationErrors: []
stdin: ''
stdout: ''
successCodes: []
temporaryFailCodes: []
