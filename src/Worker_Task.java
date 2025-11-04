import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors; 
import java.util.concurrent.Future;
import java.util.concurrent.ExecutionException;


public class Worker_Task {

    private static final String FILE_PATH = "application.log"; 
    private static final int THREAD_POOL_SIZE = 4; 
    private static final int CHUNK_SIZE = 500;


    //returns a List where each element is one line from the file.
    private static List<String> readLogFile() {

        //convert the string into a path object, which the file classes uses 
        try {
            Path path = Paths.get(FILE_PATH);

        //read all the lines from the file and return as a list of strings
            return Files.readAllLines(path);
        } catch (IOException e) {
            System.err.println("Error reading log file: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    public static void main(String[] args){
        List<String> allLines = readLogFile();
        if(allLines.isEmpty()){
            System.err.println("Error: Log file is empty or cannot be read.");
            return; 
        }

        System.out.println("Total lines read: " + allLines.size());
        
        runSingleThreadedAnalysis(allLines);
        System.out.println("\n");
        runConcurrentAnalysis(allLines);
        System.out.println("\n");
    }


    private static void runSingleThreadedAnalysis (List<String> allLines){
        System.out.println("Running single-threaded analysis...");

    //records the starting time in miliseconds
        long startTime = System.currentTimeMillis();
        int totalOccurrences = 0; 

        //processes every single line sequentially, one after the other.
        for(String line : allLines){
            if(line.contains("[ERROR]")) {
                totalOccurrences ++; 
            }
        }
        //records the end time and calcuates the duration
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime; 

        System.out.println("Single-Threaded Errors occurred: " + totalOccurrences);
        System.out.println("Single-Threaded Duration: " + duration + "ms");
    }


        private static List<List<String>> createChunks(List<String> source, int chunkSize) {

        //creatres a list where each element is itself a list of strings (a chunk)
        List<List<String>> chunks = new ArrayList<>();

        //loops through the main list contaiing the 500 lines
        for (int i = 0; i < source.size(); i += chunkSize) {

            //creates a new sub list from the main list and ensures the loop does exceed the size of the main list
            chunks.add(source.subList(i, Math.min(i + chunkSize, source.size())));
        }
        return chunks;
    }


    private static void runConcurrentAnalysis(List<String> allLines){ 

        System.out.println("Running concurrent analysis with " + THREAD_POOL_SIZE + " threads...");
        
        //calls createChunks to split the main list into smaller sub-lists; 
        List<List<String>> chunks = createChunks(allLines, CHUNK_SIZE); 

       
        //creates the thread pool and initializes four threads ready to accept tasks, more efficient than creating a new thread for every single task.
        ExecutorService executor = Executors.newFixedThreadPool(THREAD_POOL_SIZE); 

        //creates a list to hold the "future" objects representing the results of each concurret task
        List<Future<Integer>> futures = new ArrayList<>();

        long startTime = System.currentTimeMillis();

        //loops theough all the created chunks of work
        for(List<String> chunk : chunks){
        
           //creates a new LogChunkAnalyser task for each chunk
            LogChunkAnalyzer task = new LogChunkAnalyzer(chunk); 

            //submits the task to the executor for concurrent execution and stores the future result
            futures.add(executor.submit(task));
        }

    
        int totalOccurrences = 0;

        //loops through all the "promises" after all the tasks have been sumbitted 
        for (Future<Integer> future : futures) {
            try {
                // Blocks until the thread completes
                totalOccurrences += future.get(); 
            } catch (InterruptedException | ExecutionException e) {
                Thread.currentThread().interrupt();
                System.err.println("A concurrent task failed.");
            }
        }

        //Tells the ExecutorService that no new tasks will be submitted and shuts down the worker threads once they finish their current work.
        executor.shutdown(); 
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;

        System.out.println("Concurrent Errors found: " + totalOccurrences);
        System.out.println("Concurrent Duration: " + duration + "ms");
    }



}