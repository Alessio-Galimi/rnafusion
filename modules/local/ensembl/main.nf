process ENSEMBL_DOWNLOAD {
    tag "ensembl"
    label 'process_low'

    conda "bioconda::gnu-wget=1.18 conda-forge::curl=8.2.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gnu-wget:1.18--h5bf99c6_5' :
        'quay.io/biocontainers/gnu-wget:1.18--h5bf99c6_5' }"

    input:
    val ensembl_version
    val genome
    val meta

    output:
    tuple val(meta), path("Homo_sapiens.${genome}.${ensembl_version}.all.fa")        , emit: fasta
    tuple val(meta), path("Homo_sapiens.${genome}.${ensembl_version}.gtf")           , emit: gtf
    tuple val(meta), path("Homo_sapiens.${genome}.${ensembl_version}.chr.gtf")       , emit: chrgtf
    tuple val(meta), path("Homo_sapiens.${genome}.${ensembl_version}.cdna.all.fa.gz"), emit: transcript
    path "versions.yml"                                                                                                                       , emit: versions

    script:
    """
    # Download chromosome FASTAs 1–22
    for i in {1..22}; do
        curl -L -O https://ftp.ensembl.org/pub/release-${ensembl_version}/fasta/homo_sapiens/dna/Homo_sapiens.${genome}.dna.chromosome.\${i}.fa.gz
    done
    
    # Download MT, X, Y chromosomes
    for chr in MT X Y; do
        curl -L -O https://ftp.ensembl.org/pub/release-${ensembl_version}/fasta/homo_sapiens/dna/Homo_sapiens.${genome}.dna.chromosome.\${chr}.fa.gz
    done
    
    # Download GTFs
    curl -L -O https://ftp.ensembl.org/pub/release-${ensembl_version}/gtf/homo_sapiens/Homo_sapiens.${genome}.${ensembl_version}.gtf.gz
    curl -L -O https://ftp.ensembl.org/pub/release-${ensembl_version}/gtf/homo_sapiens/Homo_sapiens.${genome}.${ensembl_version}.chr.gtf.gz
    
    # Download cDNA (rename for consistency)
    curl -L -o Homo_sapiens.${genome}.${ensembl_version}.cdna.all.fa.gz \
        https://ftp.ensembl.org/pub/release-${ensembl_version}/fasta/homo_sapiens/cdna/Homo_sapiens.${genome}.cdna.all.fa.gz
    
    # Combine chromosome FASTAs
    gunzip -c Homo_sapiens.${genome}.dna.chromosome.* > Homo_sapiens.${genome}.${ensembl_version}.all.fa
    
    # Uncompress GTFs
    gunzip Homo_sapiens.${genome}.${ensembl_version}.gtf.gz
    gunzip Homo_sapiens.${genome}.${ensembl_version}.chr.gtf.gz
    
    # Record versions
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        curl: \$(curl --version | head -n 1 | awk '{print \$2}')
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
