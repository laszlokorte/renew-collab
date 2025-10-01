import java.awt.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

public class TextMeasure {

    private static String singleColon = ":";

    public static void main(String[] args) {
        Canvas canvas = new Canvas();
        try (
            BufferedReader br = new BufferedReader(
                new InputStreamReader(System.in)
            )
        ) {
            for (String line; (line = br.readLine()) != null; ) {
                String[] parts = line.split(":", 4);
                if (parts.length == 4) {
                    String font = parts[0];
                    int style = Integer.parseInt(parts[1]);
                    int size = Integer.parseInt(parts[2]);
                    String text = parts[3];

                    String[] textLines = splitLines(text);
                    Font f = new Font(font, style, size);
                    FontMetrics fm = canvas.getFontMetrics(f);

                    Size box = measureBox(fm, textLines);

                    System.out.printf("%d:%d\n", box.x, box.y);
                } else {
                    System.out.println("0:0");
                }
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private static class Size {

        public int x;
        public int y;
    }

    private static String[] splitLines(String text) {
        try {
            String[] lines = text.split(singleColon, -1);
            for (int i = 0; i < lines.length; i++) {
                lines[i] = URLDecoder.decode(lines[i], "UTF-8");
            }

            return lines;
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
    }

    private static Size measureBox(FontMetrics metrics, String[] lines) {
        Size size = new Size();

        for (int i = 0; i < lines.length; i++) {
            int width = metrics.stringWidth(lines[i]);
            int height = metrics.getHeight();
            size.x = Math.max(size.x, width);
            size.y += height;
        }

        return size;
    }
}
