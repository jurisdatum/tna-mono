package uk.gov.legislation.clml2docx;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class Util {

	static byte[] read(InputStream input) throws IOException {
		ByteArrayOutputStream buffer = new ByteArrayOutputStream();
	    int len;
	    byte[] data = new byte[1024];
	    while ((len = input.read(data, 0, data.length)) != -1) {
	        buffer.write(data, 0, len);
	    }
	    input.close();
	    buffer.flush();
	    return buffer.toByteArray();		
	}

}
