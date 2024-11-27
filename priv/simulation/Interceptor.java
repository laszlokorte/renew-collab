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
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
                     BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(process.getOutputStream()))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        writer.write(line);
                        writer.newLine();
                        writer.flush();
                    }
                    process.getOutputStream().close();
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
                      process.getInputStream().close();
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
process.getErrorStream().close();
                } catch (IOException e) {
                    e.printStackTrace(System.err);
                }
            });

            CompletableFuture.anyOf(input, output, error).join();
 process.waitFor();
            System.exit(0); // process.waitFor());
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
