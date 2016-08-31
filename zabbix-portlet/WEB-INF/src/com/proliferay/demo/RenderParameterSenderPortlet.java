package com.proliferay.demo;
 
import java.io.IOException;
 
import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;
import javax.portlet.ProcessAction;
 
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.util.bridges.mvc.MVCPortlet;
 
public class RenderParameterSenderPortlet extends MVCPortlet {
 
    @ProcessAction(name="setRenderParameter")
    public void processAction(ActionRequest request, ActionResponse response)
            throws IOException, PortletException {
 
        String name = ParamUtil.getString(request, "name","");
        System.out.println("name="+name);
        response.setRenderParameter("myname", name);
//         System.out.println("name="+name);
    }
}