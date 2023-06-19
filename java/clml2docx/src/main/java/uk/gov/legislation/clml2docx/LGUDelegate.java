package uk.gov.legislation.clml2docx;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.util.Iterator;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;

public class LGUDelegate implements Delegate {
	
	@Override
	public Resource fetch(String uri) throws IOException {
		URL url = new URL(uri);
		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		if (connection.getResponseCode() == HttpURLConnection.HTTP_MOVED_TEMP || connection.getResponseCode() == HttpURLConnection.HTTP_MOVED_PERM) {
			url = new URL(connection.getHeaderField("Location"));
			connection.getInputStream().close();
			connection.disconnect();
			connection = (HttpURLConnection) url.openConnection();
		}
		String contentType = connection.getHeaderField("Content-Type");
		InputStream input = connection.getInputStream();
		byte[] data = Util.read(input);
	    connection.disconnect();
	    if (contentType.equals("binary/octet-stream")) {
	    	contentType = URLConnection.guessContentTypeFromStream(new ByteArrayInputStream(data));
	    	if (contentType == null) {
	    		ImageInputStream iis = ImageIO.createImageInputStream(new ByteArrayInputStream(data));
	    		Iterator<ImageReader> imageReaders = ImageIO.getImageReaders(iis);
	    		if (imageReaders.hasNext()) {
	    		    ImageReader reader = (ImageReader) imageReaders.next();
	    		    contentType = "image/" + reader.getFormatName().toLowerCase();
	    		} else {
	    			contentType = "image/gif";	// http://www.legislation.gov.uk/uksi/2018/4/images/uksi_20180004_en_001
	    		}
	    	}
	    } else if (contentType.equals("application/pdf")) {
	    	contentType = URLConnection.guessContentTypeFromStream(new ByteArrayInputStream(data));
	    	if (contentType == null) {
	    		ImageInputStream iis = ImageIO.createImageInputStream(new ByteArrayInputStream(data));
	    		Iterator<ImageReader> imageReaders = ImageIO.getImageReaders(iis);
	    		if (imageReaders.hasNext()) {
	    		    ImageReader reader = (ImageReader) imageReaders.next();
	    		    contentType = "image/" + reader.getFormatName().toLowerCase();
	    		} else {
	    			contentType = "application/pdf";
	    		}
	    	}
	    }
	    return new Resource(data, contentType);
	}

}
