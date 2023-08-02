// Script parameters
params.genome_dir = "$projectDir/resources/star/"
params.annotation_file = "$projectDir/resources/GCA_000001405.15_GRCh38_full_analysis_set.refseq_annotation.gtf"

workflow {
  def get_inputSequence = Channel.fromPath( "$projectDir/input/library.fa" )
  
  alignToReference(params.genome_dir, params.annotation_file, get_inputSequence)
  bamToBed(alignToReference.out)
  compareGenes(params.annotation_file, bamToBed.out)
  extractGeneMatrix(compareGenes.out)
}


process alignToReference {

  publishDir "$projectDir/output/alignToReference", mode: 'copy', overwrite: true

  input:
    path genome_dir
    path annotation_file
    path 'inputSequence.fa'
  
  output:
    path 'Aligned.out.sam'
    

  """
  STAR \
  --runThreadN 14 \
  --genomeDir $genome_dir \
  --sjdbGTFfile $annotation_file \
  --readFilesIn inputSequence.fa
  """
}


process bamToBed {

  publishDir "$projectDir/output/bamToBed", mode: 'copy', overwrite: true

  input:
    path alignment
  
  output:
    path 'Aligned.out.bed'

    
  """

  bedtools bamtobed -i $alignment > Aligned.out.bed
  
  """
}

process compareGenes {

  publishDir "$projectDir/output/compareGenes", mode: 'copy', overwrite: true

  input:
    path annotation_file
    path alignment_bed
  
  output:
    path 'Aligned.out.sorted.genes.bed'
    
  """

  #convert GTF to BED
  awk '{ if (\$0 ~ "transcript_id") print \$0; else print \$0" transcript_id \"\";"; }' $annotation_file | gtf2bed - > annotation.bed

  #sort bed files
  sort-bed $alignment_bed > alignment_bed_sorted
  grep -v exon annotation.bed | sort-bed -  > annotation.noexons.sorted.bed

  #intersect bed files
  bedmap --echo --echo-map-id-uniq --bp-ovr 1 --delim '\t' alignment_bed_sorted annotation.noexons.sorted.bed > Aligned.out.sorted.genes.bed

  """
}

process extractGeneMatrix {

  publishDir "$projectDir/output/extractGeneMatrix", mode: 'copy', overwrite: true

  input:
    path alignment_bed
  
  output:
    path 'GeneMatrix.tsv'

    
  """

  Rscript $projectDir/templates/extractGeneMatrix.R --input $alignment_bed --output GeneMatrix.tsv
  
  """
}




