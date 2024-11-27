JAVAC = javac
JAR = jar
SRC = Interceptor.java
CLASS = Interceptor.class
MANIFEST = manifest.txt
JAR_FILE = Interceptor.jar

all: $(JAR_FILE)

$(CLASS): $(SRC)
	$(JAVAC) $(SRC)

$(JAR_FILE): $(CLASS) $(MANIFEST)
	$(JAR) cmf $(MANIFEST) $(JAR_FILE) $(CLASS)

clean:
	rm -f $(CLASS) $(JAR_FILE)

.PHONY: all clean
