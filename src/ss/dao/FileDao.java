package ss.dao;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

public class FileDao {
	
	public int getCount() {
		int count = 0;
		// Load the file with the counter
		FileReader fileReader = null;
		BufferedReader bufferedReader = null;

		try {
			File f = new File("FileCounter.initial");
			if (!f.exists()) {
				f.createNewFile();
				PrintWriter writer = new PrintWriter(new FileWriter(f));
				writer.println(0);
			}
			
			fileReader = new FileReader(f);
			bufferedReader = new BufferedReader(fileReader);
			String initial = bufferedReader.readLine();
			count = Integer.parseInt(initial);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		if (bufferedReader != null) {
			try {
				bufferedReader.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return count;
	}

	public void save(int count) throws Exception {
		FileWriter fileWriter = null;
		PrintWriter printWriter = null;
		fileWriter = new FileWriter("FileCounter.initial");
		printWriter = new PrintWriter(fileWriter);
		printWriter.println(count);

		// Make sure to close the file
		if (printWriter != null) {
			printWriter.close();
		}
	}
}
