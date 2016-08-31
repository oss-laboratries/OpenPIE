package com.proliferay.demo;
 
import java.io.IOException;
 
import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
 
import com.liferay.util.bridges.mvc.MVCPortlet;
 
public class RenderParameterReceiverPortlet extends MVCPortlet{
 
    @Override
    public void doView(RenderRequest renderRequest,
            RenderResponse renderResponse) throws IOException, PortletException {
 
        /**
         * Reading public render parameter in render phase
         */
        String myname = renderRequest.getParameter("myname");
        System.out.println("=========myname======="+myname);
        super.doView(renderRequest, renderResponse);
    }
}
