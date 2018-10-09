# Sequence QC and BLAST homework assignment for CS640
## Due as a pull request on Tuesday, October 16, 2018 before 11:59 pm

The **goal of this assignment** is to work through the first stages of a realistic analysis workflow, starting with downloading of fastq files, through QC checks, trimming, and finally BLASTing them against a local copy of GenBank (on the server). The data we will be using is from the NCBI Sequence Read Archive study number ERP022657. A summary of the information is available [here](https://www.ncbi.nlm.nih.gov/Traces/study/?WebEnv=NCID_1_128047291_130.14.22.33_5555_1505945515_1626731749_0MetA0_S_HStore&query_key=5). The metadata from this study is included in the git repository for this assignment in a `data/metadata` directory.

Here's the abstract from the [original study](https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?study=ERP022657) by Fierer et al.:

> Recent work has demonstrated that the diversity of skin-associated bacterial communities is far higher than previously recognized, with a high degree of interindividual variability in the composition of bacterial communities. Given that skin bacterial communities are personalized, we hypothesized that we could use the residual skin bacteria left on objects for forensic identification, matching the bacteria on the object to the skin-associated bacteria of the individual who touched the object. Here we describe a series of studies demonstrating the validity of this approach. We show that skin-associated bacteria can be readily recovered from surfaces (including single computer keys and computer mice) and that the structure of these communities can be used to differentiate objects handled by different individuals, even if those objects have been left untouched for up to 2 weeks at room temperature. Furthermore, we demonstrate that we can use a high-throughput pyrosequencing-based approach to quantitatively compare the bacterial communities on objects and skin to match the object to the individual with a high degree of certainty. Although additional work is needed to further establish the utility of this approach, this series of studies introduces a forensics approach that could eventually be used to independently evaluate results obtained using more traditional forensic practices.

You will create two primary files for this assignment. The first is a bash fastq sequence processing script that completes all steps of a pipeline from downloading the data from NCBI through to using BLAST to identify top matches in the GenBank nucleotide database. You will then choose one particular focal area of interest in the dataset to write up a short report discussing and interpreting some of your preliminary findings. This discussion/interpretation should be 800-1000 words, and formatted as a markdown file. Remember that you can make section and subsection headings in markdown.

The guidance for this assignment is a little less strict than in previous assignments. I am leaving it to you to add appropriate commenting to your scripts, and to make sure your project directory is well organized.

You should use the BLAST results as a launching off point to do some additional research on the taxa you find. You can use Google Scholar or some other tool to search the peer-reviewed literature. This report could look at, for example: different bacterial taxa on male vs female hands, or the similarity of mouse surfaces to student hands, or just what is found on computer mice, etc. It matters less to me what specific aspect of the data you focus on, and more important that you spend some time researching the biological implications of the taxa you identify using the BLAST search.

Please follow the instructions carefully and read them all before getting started.

This assignment will be worth 20 points. The grading breakdown will be as follows (notice it is slightly different from past assignments):

* 10 points - Completes all required steps, including the analysis report and associated literature search (as outlined below)
* 3 points - Scripts are appropriately commented and well organized
* 3 points - Appropriate use of git to version control the steps, including adding and committing the appropriate files at the specific steps below, and writing informative and appropriately formatted commit messages
* 4 points - Passes Travis CI automated style checks

You must submit your work as a Pull Request to the class organization ('2018-usfca-cs-640-fall') on GitHub by 11:59 pm on Tuesday, October 16 for full credit. Late assignments will not be accepted, since we will be peer reviewing the code after it is submitted.

Steps:

1. Fork this repository to your own GitHub account.
2. Connect to tule.usfca.edu with `ssh yourusername@tule.usfca.edu -p 80XX` using the username, password, and port (that's the 80XX part of the command) that were emailed to you. You will need to connect to the VPN before you do this if you are off campus.
3. Start a new named `tmux` session on the server ([tmux cheat sheet here](https://gist.github.com/MohamedAlaa/2961058)).
4. Clone your fork of the assignment repository down to the server.
5. Go into the assignment directory from the command line.
6. Make `data/raw_data` and `output/fastqc` directories using `mkdir -p data/raw_data output/fastqc`.
7. Create a new script file to run the pipeline.
8. Add code to download the list of files in the run table to the raw data directory.

```
# the pipe and tail -n +2 is a handy way to exclude the first line
for SRA_number in $(cut -f 6 data/metadata/fierer_forensic_hand_mouse_SraRunTable.txt | tail -n +2)
do
    fastq-dump -v $SRA_number -O data/raw_data
done
```

9. Add code to create QC reports for each of the runs using the `FastQC` program. To view these reports, you'll need to connect to the server using the SFTP protocol and the program 'Cyberduck' to transfer the files to your laptop. You need to use the same username, password, and port as you used to connect via SSH. Once they are transferred, you can open the `.html` files in your web browser to view them.

```
fastqc data/raw_data/*.fastq --outdir=output/fastqc
```

10. Add code to trim the sequences based on their quality scores. This set of parameters trims leading or trailing Ns, discards any sequences below a length of 150 base pairs, and uses a sliding window average method to cut off reads when the base score drops below 25. You will need to adjust the following command to do the trimming in a for loop. Don't forget to make the output directory before running this.

```
# Info on the Trimmomatic tool available here: http://www.usadellab.org/cms/index.php?page=trimmomatic
TrimmomaticSE -threads 2 -phred33 data/raw_data/ERR1942280.fastq data/trimmed/$(basename -s .fastq ERR1942280.fastq).trim.fastq LEADING:5 TRAILING:5 SLIDINGWINDOW:8:25 MINLEN:150
```

11. Add code to convert fastq files into fasta files so they can be used as BLAST queries. You'll need to do this using a for loop. The specific syntax for using bioawk to do this is as follows (you'll need to set up the for loop appropriately, and make sure files go to the appropriate output directories). Make sure you convert the *trimmed* files and not the *untrimmed* ones:

```
bioawk -c fastx '{print ">"$name"\n"$seq}' data/trimmed/filename.trim.fastq
```

12. Add code to use `blastn` to search for the top match of each sequence against the `nt` database. The following command will output a csv file called `blast_results.csv` with one row for each query sequence in `query_seqs.fasta`. I recommend you put this in a for loop as well, so you can BLAST each of the different samples files without having to write out the code manually. *If you don't change the `-out` parameter before running this on different files, it will overwrite the output.* I would recommend having these `csv` files get stored in a subdirectory in the `output` folder. This step may take many hours to run, and so it is essential that you do it inside of a `tmux` session. You may want to test this once to make sure it works on a single file, and then you can leave it to run overnight on all the files.

```
# options and what they're for:
# -db sets which database to use, in this case the nucleotide database
# -num_threads is how many different processor threads to use
# -outfrmt is the output format, further info available here:
# https://www.ncbi.nlm.nih.gov/books/NBK279675/
# -out is the filename to save the results in
# -max_target_seqs is the number of matches ot return for each query
# -negative_gilist tells BLAST which sequences to exclude from matches
# This cuts down on the number of uncultured or environmental matches
# -query is the fasta file of sequences we want to search for matches to

blastn -db /blast-db/nt -num_threads 2 -outfmt '10 sscinames std' -out blast_results.csv -max_target_seqs 1 -negative_gilist /blast-db/2018-09-19_environmental_sequence.gi -query query_seqs.fasta
```

13. Commit the script as you work on it, whenever you make a good chunk of progress. Make sure you write
   an [appropriate commit message](https://chris.beams.io/posts/git-commit/).
14. After you have finished the script and it successfully runs at the command line, be sure to add a commit marking this milestone (and push back up to GitHub just to be safe!).
15. You can use `cut`, `sort`, and `uniq -c` to help you summarize the results from the blast search.
16. Using `nano`, write a markdown formatted file named `2017-10-16_preliminary_BLAST_analysis.md` (changing date as needed depending on when you write it) that contains both a section summarizing the QC checks you ran with `FastQC` (did the sequences look to be of sufficient quality? Were there any samples that were significantly worse than the other or different in some sort of obvious way?) as well as some preliminary research into the organisms you found using BLAST. You shouldn't try to look everything up in your target samples, but pick some of the more common strains that you find and see what you can learn about them by doing a brief literature search.
17. Add and commit this analysis report file as well, once you are done.
18. Once that's all done, add, commit, and push everything back to your fork of the original repository on GitHub with `git push -u origin master`. Remember that you can only push what you have committed, so be sure all of your work is committed. Be sure to save your files often, and check `git status` frequently as you work.
19. Submit a Pull Request back to the organization repository to submit your assignment. Make sure the Pull Request (PR) has a useful description of the changes you made.
20. When you submit the pull request, a set of automated tests will run on it, to check that you have fixed all of the potential code style and syntax errors in your scripts. If you want to rigorously check for any syntax errors while you are working on the code, you can use the 'shellcheck' program. We talked about how to do this in class.

**Pro Tip:** Save often, commit often, push often, and use `tmux`! If you have any questions or need clarification of what it is I'd like you to do, please ask me sooner rather than later so you stay on the right track for completing this assignment on time.
