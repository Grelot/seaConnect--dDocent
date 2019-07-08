configfile: "01-info_files/config.yaml"


FASTQFILES=config["fastq"]

rule all:
    input:
        directory(expand({runpool}, runpool=FASTQFILES)),        
        directory(expand('03-samples/{runpool}_clone_filtered', runpool=FASTQFILES)),
        expand('10-logs/process_radtags/{runpool}.log',runpool=FASTQFILES),
        expand('10-logs/clone_filter/{runpool}.log',runpool=FASTQFILES)

### demultiplexing
rule process_radtags:
    input:
        '02-raw/{runpool}/'
    output:
        directory('03-samples/{runpool}')
    params:
        enzymes=config["process_radtags"]["enzyme"],        
        trim_length=config["process_radtags"]["trim_length"],
        score_limit=config["process_radtags"]["score_limit"],
        windows_size=config["process_radtags"]["sliding_windows_size"],
        adapter_mm=config["process_radtags"]["adapter_mm"],
        encoded=config["process_radtags"]["encoded"],
        adapter_1=config["process_radtags"]["adapter_1"],        
        barcode_dist=config["process_radtags"]["barcode_dist"]        
    log:
        '10-logs/process_radtags/{runpool}.log'
    singularity:
        'docker://mckaydavis/ddocent'
    shell:
        '''mkdir -p {output};
        process_radtags -i gzfastq -p {input} -o {output} -b 01-info_files/barcodes.txt -c -r -t {params.trim_length} --adapter_mm {params.adapter_mm} --adapter_1 {params.adapter_1} --barcode_dist {params.barcode_dist} -w {params.windows_size} -s {params.score_limit} -E {params.encoded} --renz_1 {params.enzyme[0]} --renz_2 {params.enzyme[1]} 2> {log}'''
