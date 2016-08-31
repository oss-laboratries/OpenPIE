

import java.io.IOException;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;
import javax.portlet.ProcessAction;

import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.util.bridges.mvc.MVCPortlet;

/**
 *
 * @author Hamidul Islam
 *
 */
public class RenderParameterSenderPortlet extends MVCPortlet {

    @ProcessAction(name="setRenderParameter")
    public void processAction(ActionRequest request, ActionResponse response)
            throws IOException, PortletException {

        String id = ParamUtil.getString(request, "id","");
        String name = ParamUtil.getString(request, "name","");
        /**
         * myname is same as like normal parameter. But it is configured
         * as public portlet.xml file
         * Any other portlet can read this parameter
         *
         * To read this parameter in your portlet you
         * should tell your portlet that you are going to
         * use public render parameter. That configuration is done again in
         * portlet.xml
         */
        System.out.println("senderID="+id);
        System.out.println("senderNAME="+name);
        response.setRenderParameter("pname", name);
        response.setRenderParameter("pid", id);
    }
}
