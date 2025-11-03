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

    // ----------------------------------------------------------------------
    // Utility: File Reading
    // ----------------------------------------------------------------------
    private static List<String> readLogFile() {
        try {
            Path path = Paths.get(FILE_PATH);
            return Files.readAllLines(path);
        } catch (IOException e) {
            System.err.println("Error reading log file: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    // ----------------------------------------------------------------------
    // Main Method
    // ----------------------------------------------------------------------
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

    // ----------------------------------------------------------------------
    // Single-Threaded Analysis
    // ----------------------------------------------------------------------
    private static void runSingleThreadedAnalysis (List<String> allLines){
        System.out.println("Running single-threaded analysis...");

        long startTime = System.currentTimeMillis();
        int totalOccurrences = 0; 

        for(String line : allLines){
            if(line.contains("[ERROR]")) {
                totalOccurrences ++; 
            }
        }
        
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime; 

        System.out.println("Single-Threaded Errors occurred: " + totalOccurrences);
        System.out.println("Single-Threaded Duration: " + duration + "ms");
    }

    // ----------------------------------------------------------------------
    // Concurrent Analysis (Fixed and Completed)
    // ----------------------------------------------------------------------
    // Changed access modifier from public to private for good practice since 
    // it's a utility method only called by main() in this class.
    private static void runConcurrentAnalysis(List<String> allLines){ 

        System.out.println("Running concurrent analysis with " + THREAD_POOL_SIZE + " threads...");
        
        // FIX 3: Removed 'new' keyword
        List<List<String>> chunks = createChunks(allLines, CHUNK_SIZE); 

        // FIX 2: Used Executors class (plural)
        ExecutorService executor = Executors.newFixedThreadPool(THREAD_POOL_SIZE); 
        List<Future<Integer>> futures = new ArrayList<>();

        long startTime = System.currentTimeMillis();

        for(List<String> chunk : chunks){
            // Assumes LogChunkAnalyzer class is available
            LogChunkAnalyzer task = new LogChunkAnalyzer(chunk); 
            futures.add(executor.submit(task));
        }

        // --- CLOSING LOGIC (MISSING PART) ---
        int totalOccurrences = 0;
        for (Future<Integer> future : futures) {
            try {
                // Blocks until the thread completes
                totalOccurrences += future.get(); 
            } catch (InterruptedException | ExecutionException e) {
                Thread.currentThread().interrupt();
                System.err.println("A concurrent task failed.");
            }
        }

        executor.shutdown(); 
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;

        System.out.println("Concurrent Errors found: " + totalOccurrences);
        System.out.println("Concurrent Duration: " + duration + "ms");
    }

    // ----------------------------------------------------------------------
    // Utility: Chunk Creator (Essential for Concurrency)
    // ----------------------------------------------------------------------
    private static List<List<String>> createChunks(List<String> source, int chunkSize) {
        List<List<String>> chunks = new ArrayList<>();
        for (int i = 0; i < source.size(); i += chunkSize) {
            chunks.add(source.subList(i, Math.min(i + chunkSize, source.size())));
        }
        return chunks;
    }

}