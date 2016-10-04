<%@page import="org.opencps.dossiermgt.util.DossierMgtUtil"%>
<%@page import="org.opencps.util.PortletUtil"%>
<%@page import="org.opencps.datamgt.service.DictCollectionLocalServiceUtil"%>
<%@page import="org.opencps.datamgt.model.DictCollection"%>
<%@page import="javax.portlet.PortletRequest"%>
<%@page import="org.opencps.util.WebKeys"%>
<%@page import="com.liferay.portal.kernel.portlet.LiferayWindowState"%>
<%@page import="com.liferay.portlet.PortletURLFactoryUtil"%>
<%@page import="com.liferay.portal.kernel.json.JSONFactoryUtil"%>
<%@page import="com.liferay.portal.kernel.json.JSONObject"%>
<%@page import="org.opencps.util.PortletPropsValues"%>
<%@page import="org.opencps.dossiermgt.search.DossierDisplayTerms"%>
<%@page import="com.liferay.portal.kernel.language.LanguageUtil"%>
<%@page import="org.opencps.processmgt.util.ProcessOrderUtils"%>
<%
/**
 * OpenCPS is the open source Core Public Services software
 * Copyright (C) 2016-present OpenCPS community
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
%>

<%@page import="com.liferay.portal.kernel.dao.search.SearchEntry"%>
<%@page import="com.liferay.portal.kernel.log.Log"%>
<%@page import="com.liferay.portal.kernel.log.LogFactoryUtil"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="javax.portlet.PortletURL"%>
<%@page import="org.opencps.datamgt.model.DictItem"%>
<%@page import="org.opencps.datamgt.service.DictItemLocalServiceUtil"%>
<%@page import="org.opencps.dossiermgt.bean.ServiceBean"%>
<%@page import="org.opencps.dossiermgt.model.ServiceConfig"%>
<%@page import="org.opencps.dossiermgt.search.ServiceSearch"%>
<%@page import="org.opencps.dossiermgt.search.ServiceSearchTerms"%>
<%@page import="org.opencps.dossiermgt.service.ServiceConfigLocalServiceUtil"%>
<%@page import="org.opencps.servicemgt.model.ServiceInfo"%>
<%@page import="org.opencps.servicemgt.service.ServiceInfoLocalServiceUtil"%>
<%@page import="org.opencps.servicemgt.util.ServiceUtil"%>
<%@page import="org.opencps.util.PortletConstants"%>

<%@ include file="../../init.jsp"%>

<%
	
	String backURL = ParamUtil.getString(request, "backURL");

	long serviceDomainId = ParamUtil.getLong(request, "serviceDomainId");
	
	long administrationId = ParamUtil.getLong(request, "administrationId");
	
	String dictItemCode = ParamUtil.getString(request, "dictItemCode");
	
	long govAgencyId = ParamUtil.getLong(request, "govAgencyId");
	
	String dossierStatus = ParamUtil.getString(request, "dossierStatus", StringPool.BLANK);
	
	String tabs1 = ParamUtil.getString(request, "tabs1", DossierMgtUtil.TOP_TABS_DOSSIER);
	
	List<DictItem> dictItems = PortletUtil.getDictItemInUseByCode(themeDisplay.getScopeGroupId(), 
			PortletPropsValues.DATAMGT_MASTERDATA_SERVICE_DOMAIN, 
			PortletConstants.TREE_VIEW_DEFAULT_ITEM_CODE);
	
	JSONObject arrayParam = JSONFactoryUtil
		    .createJSONObject();
	arrayParam.put(DossierDisplayTerms.SERVICE_DOMAIN_ID, (serviceDomainId > 0) ? String.valueOf(serviceDomainId):StringPool.BLANK);
	arrayParam.put("administrationId", (administrationId > 0) ? String.valueOf(administrationId):StringPool.BLANK);
	arrayParam.put("backURL", currentURL);
	arrayParam.put("isListServiceConfig", String.valueOf(true));
%>

<liferay-ui:header
	backURL="<%= backURL %>"
	title="service-list"
/>

<aui:row>
	<aui:col width="100" >

		<liferay-util:include page='<%=templatePath + "toolbar.jsp" %>' servletContext="<%=application %>" />

		<div class="opencps-searchcontainer-wrapper default-box-shadow radius8">
		
		<div id="serviceDomainIdTree" class="openCPSTree"></div>
		
		<%
		
		String serviceDomainJsonData = ProcessOrderUtils.generateTreeViewMappingAdminCode(
				PortletPropsValues.DATAMGT_MASTERDATA_SERVICE_ADMINISTRATION, 
				dictItemCode, 
				LanguageUtil.get(locale, "filter-by-service-domain-left") , 
				PortletConstants.TREE_VIEW_LEVER_2, 
				"radio",
				false,
				renderRequest);
		%>
		
	</div>
		
	<aui:script use="liferay-util-window,liferay-portlet-url">

	var serviceDomainId = '<%=String.valueOf(serviceDomainId) %>';
	var serviceDomainJsonData = '<%=serviceDomainJsonData%>';
	var arrayParam = '<%=arrayParam.toString() %>';
	AUI().ready(function(A){
		buildTreeView("serviceDomainIdTree", 
				"<%=DossierDisplayTerms.SERVICE_DOMAIN_ID %>", 
				serviceDomainJsonData, 
				arrayParam, 
				'<%= PortletURLFactoryUtil.create(request, WebKeys.DOSSIER_MGT_PORTLET, themeDisplay.getPlid(), PortletRequest.RENDER_PHASE) %>', 
				'<%=templatePath + "display/20_80_servicelist_05.jsp" %>', 
				'<%=LiferayWindowState.NORMAL.toString() %>', 
				'normal',
				null,
				serviceDomainId,
				'<%=renderResponse.getNamespace() %>');
	});
	
</aui:script>
	</aui:col>
</aui:row>
<portlet:actionURL var="keywordsAutoCompleteURL" name="keywordsAutoComplete"/>

<script type="text/javascript">

$("#<portlet:namespace/>keywords1").autocomplete({
									
	delay: 200,
						
	minLength: 1,
	
	source: function( request, response ) {
        $.ajax({
            dataType: "json",
            type : 'POST',
            data: {
            	<portlet:namespace/>keywords: request.term,
            	<portlet:namespace/>administrationId: '<%=administrationId %>'
            },
            url: '<%=keywordsAutoCompleteURL.toString() %>',
            success: function(data) {

                response( $.map( data, function(value, key) {
                	return {                
				 		label: value,                                                
				 		value:  key                                            
				 	}    
                }));
            }
        });
    },
							
	focus: function(event, ui) {
		// prevent autocomplete from updating the textbox
		event.preventDefault();
	},
									
	select: function(event, ui) {
		// prevent autocomplete from updating the textbox
		event.preventDefault();
		// redirect page
		var portletURL = Liferay.PortletURL.createURL('<%= PortletURLFactoryUtil.create(request, WebKeys.P26_SUBMIT_ONLINE, PortalUtil.getPlidFromPortletId(themeDisplay.getScopeGroupId(),  WebKeys.P26_SUBMIT_ONLINE), PortletRequest.RENDER_PHASE) %>');
		portletURL.setParameter("mvcPath", "/html/portlets/dossiermgt/submit/dossier_submit_online.jsp");
		portletURL.setWindowState('<%=LiferayWindowState.NORMAL.toString() %>'); 
		portletURL.setPortletMode("normal");
		portletURL.setParameter("serviceinfoId", ui.item.value + "");
		portletURL.setParameter("backURL", "<%=currentURL.toString() %>");
		
		window.location = portletURL.toString();
// 		alert(ui.item.label + "/" + ui.item.value);
	},
									
	change: function(event, ui) {
		// prevent autocomplete from updating the textbox
		event.preventDefault();
		console.log(1);
	}
									
});

</script>
<%!
	private Log _log = LogFactoryUtil.getLog("html.portlets.dossiermgt.frontoffice.frontofficeservicelist.jsp");
%>
