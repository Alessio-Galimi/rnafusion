process ENSEMBL_DOWNLOAD {
    tag "ensembl"
    label 'process_low'

    conda "bioconda::gnu-wget=1.18"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gnu-wget:1.18--h5bf99c6_5' :
        'quay.io/biocontainers/gnu-wget:1.18--h5bf99c6_5' }"

    input:
    val ensembl_version
    val genome
    val meta
    path ensembl_files from '/bioinformatics_resources/genome_references/human/GRCh38/rnafusion_third_build/raw_ensembl/*'


    output:
    tuple val(meta), path("Homo_sapiens.${genome}.${ensembl_version}.all.fa")        , emit: fasta
    tuple val(meta), path("Homo_sapiens.${genome}.${ensembl_version}.gtf")           , emit: gtf
    tuple val(meta), path("Homo_sapiens.${genome}.${ensembl_version}.chr.gtf")       , emit: chrgtf
    tuple val(meta), path("Homo_sapiens.${genome}.${ensembl_version}.cdna.all.fa.gz"), emit: transcript
    path "versions.yml"                                                                                                                       , emit: versions


    script:
    """    
    gunzip -c Homo_sapiens.${genome}.dna.chromosome.* > Homo_sapiens.${genome}.${ensembl_version}.all.fa
    gunzip -c Homo_sapiens.${genome}.${ensembl_version}.gtf.gz > Homo_sapiens.${genome}.${ensembl_version}.gtf
    gunzip -c Homo_sapiens.${genome}.${ensembl_version}.chr.gtf.gz > Homo_sapiens.${genome}.${ensembl_version}.chr.gtf

    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(echo wget -V 2>&1 | grep "GNU Wget" | cut -d" " -f3)
    END_VERSIONS
    """
    stub:
    """
    touch "Homo_sapiens.${genome}.${ensembl_version}.all.fa"
    touch "Homo_sapiens.${genome}.${ensembl_version}.gtf"
    touch "Homo_sapiens.${genome}.${ensembl_version}.chr.gtf"
    touch "Homo_sapiens.${genome}.${ensembl_version}.cdna.all.fa.gz"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(echo wget -V 2>&1 | grep "GNU Wget" | cut -d" " -f3 > versions.yml)
    END_VERSIONS
    """

}
