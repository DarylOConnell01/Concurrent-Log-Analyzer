import java.util.List;
import java.util.concurrent.Callable;

/**
 * Represents a worker task that processes a small chunk of log lines 
 * and returns the count of errors found.
 * This class implements Callable, allowing it to be executed concurrently 
 * by the ExecutorService.
 */
public class LogChunkAnalyzer implements Callable<Integer> {
    
    // The specific block of log lines this thread is responsible for
    private final List<String> logLines; 

    /**
     * Constructor: Takes the chunk of data to process.
     * @param lines A sub-list of lines from the main log file.
     */
    public LogChunkAnalyzer(List<String> lines) {
        this.logLines = lines;
    }

    /**
     * The core logic executed by the thread.
     * @return The number of [ERROR] entries found in this chunk.
     */
    @Override
    public Integer call() {
        int errorCount = 0;
        
        // Iterate through the lines and count occurrences of "[ERROR]"
        for (String line : logLines) {
            if (line.contains("[ERROR]")) {
                errorCount++;
            }
        }
        
        // Optional: Print this to see which thread processed the chunk
        // System.out.println("Thread processed " + logLines.size() + " lines.");
        
        return errorCount;
    }
}