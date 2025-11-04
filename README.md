## Getting StJava Concurrent log Analyser 
A high performance command line application built to improve and reduce the file processing by utilising Java’s multi thread and concurency API’s. This project demonstrates a core understanding of the parallel computing necessary for scalable back end development. 


The Problem and Solution
Old traditional processing is inherently sequential, and when it comes to analysing large log files i.e 200,00, the overall process becomes extremely slow and waste available CPU power. 

What I had performed with the help of AI was get the large log files and partitioned them into manage chunks i.e from the code I hardcoded to 500 per lines per task, but of course was a small scale as it would take a long time of me individually having to write many lines of text on a text file. These chunks are then submitted to a thread pool(ExectionerService) and these multiple threads process the chunks simultaneously and report their individual results. The main program safely aggregates the results. 

Techicanl Deep Dive
Concurency(java.util.concurrent): Implemented a thread safe solution using the “ExecutorSerice” framework, specifically a “FixedThreadPool”, to allow me to control and reuse the fixed number of threads. 

I utilised the “Callable<Integer>” interface in the “LogChunkAnalyser” to define a task that returns a result. This essential for worker threads that need to report back data. 

Employed “Future<Integer>” objects to manage the promises of results from the concurrent threads and the “.get()” method to safely arregate the final total, ensuring that all the threads were synchronised. 

Implemented custom logic “creatChunks” method to effectively divide the workload for parallel processing, balancing the I/O latency with thread management overhead. 

Explicitly calculates the time taken by the single-threaded (baseline) and multi-threaded executions to provide quantifiable proof of efficiency.

Sample Peformace






