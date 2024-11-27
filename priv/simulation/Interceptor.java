import java.io.*;
import java.util.concurrent.*;

public class Interceptor {
    public static void main(String[] args) {
        if (args.length == 0) {
            System.err.println("Usage: java Interceptor <command> [args...]");
            System.exit(1);
        }

        Process childProcess = null;
        final ProcessBuilder processBuilder = new ProcessBuilder(args);

        try {
            final Process process = processBuilder.start();
            childProcess = process;

            Runtime.getRuntime().addShutdownHook(new Thread(() -> process.destroy()));

            CompletableFuture<Void> input = CompletableFuture.runAsync(() -> {
                try (OutputStream processInput = process.getOutputStream();
                     InputStream stdin = System.in) {
                    byte[] buffer = new byte[1024];
                    int bytesRead;
                    while ((bytesRead = stdin.read(buffer)) != -1) {
                        processInput.write(buffer, 0, bytesRead);
                        processInput.flush();
                    }
                } catch (IOException e) {
                    e.printStackTrace(System.err);
                }
            });

            CompletableFuture<Void> output = CompletableFuture.runAsync(() -> {
                try (InputStream processOutput = process.getInputStream();
                     OutputStream stdout = System.out) {
                    byte[] buffer = new byte[1024];
                    int bytesRead;
                    while ((bytesRead = processOutput.read(buffer)) != -1) {
                        stdout.write(buffer, 0, bytesRead);
                        stdout.flush();
                    }
                } catch (IOException e) {
                    e.printStackTrace(System.err);
                }
            });

            CompletableFuture<Void> error = CompletableFuture.runAsync(() -> {
                try (InputStream processError = process.getErrorStream();
                     OutputStream stderr = System.err) {
                    byte[] buffer = new byte[1024];
                    int bytesRead;
                    while ((bytesRead = processError.read(buffer)) != -1) {
                        stderr.write(buffer, 0, bytesRead);
                        stderr.flush();
                    }
                } catch (IOException e) {
                    e.printStackTrace(System.err);
                }
            });

            CompletableFuture.anyOf(input, output, error).join();
            
            process.destroy();

            process.waitFor();
            System.exit(0);
        } catch (IOException | InterruptedException e) {
            e.printStackTrace(System.err);
            System.exit(1);
        } finally {
            if (childProcess != null) {
                childProcess.destroyForcibly();
            }
        }
    }
}
