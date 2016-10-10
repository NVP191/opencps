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
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 */

package org.opencps.backend.exc;

import javax.jms.JMSException;
import javax.naming.NamingException;

import org.opencps.backend.message.UserActionMsg;
import org.opencps.backend.util.BackendUtils;
import org.opencps.jms.context.JMSHornetqContext;
import org.opencps.jms.message.SubmitDossierMessage;
import org.opencps.jms.message.SubmitPaymentFileMessage;
import org.opencps.jms.util.JMSMessageUtil;
import org.opencps.paymentmgt.model.PaymentFile;
import org.opencps.paymentmgt.service.PaymentFileLocalServiceUtil;
import org.opencps.util.PortletConstants;
import org.opencps.util.WebKeys;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.messaging.Message;
import com.liferay.portal.kernel.messaging.MessageListener;
import com.liferay.portal.kernel.messaging.MessageListenerException;

/**
 * @author khoavd
 */
public class MsgOutFrontOffice implements MessageListener {

	@Override
	public void receive(Message message)
		throws MessageListenerException {

		_doReceiveDossier(message);
	}

	private void _doReceiveDossier(Message message) {

		System.out.println("DONE MSGOUT_FO///////////////////////////////");

		UserActionMsg userActionMgs =
			(UserActionMsg) message.get("msgToEngine");

		long dossierId = userActionMgs.getDossierId();

		boolean trustServiceMode = BackendUtils.checkServiceMode(dossierId);

		if (!trustServiceMode) {
			JMSHornetqContext context = null;
			try {

				// JMSContext context =
				// JMSMessageUtil.createProducer(
				// userActionMgs.getCompanyId(),
				// userActionMgs.getGovAgencyCode(), true,
				// WebKeys.JMS_QUEUE_OPENCPS.toLowerCase(),
				// WebKeys.JMS_QUEUE_OPENCPS.toLowerCase(), "remote",
				// "jmscore");

				context =
					JMSMessageUtil.createHornetqProducer(
						userActionMgs.getCompanyId(),
						userActionMgs.getGovAgencyCode(), true,
						WebKeys.JMS_QUEUE_OPENCPS_FRONTOFFICE.toLowerCase(),
						WebKeys.JMS_QUEUE_OPENCPS_FRONTOFFICE.toLowerCase(),
						"remote", "hornetq");

				if (userActionMgs.getAction().contentEquals(
					PortletConstants.PAYMENT_TYPE)) {

					SubmitPaymentFileMessage submitPaymentFileMessage =
						new SubmitPaymentFileMessage(context);

					PaymentFile paymentFile =
						PaymentFileLocalServiceUtil.fetchPaymentFile(userActionMgs.getPaymentFileId());

					submitPaymentFileMessage.sendHornetMessage(paymentFile);

				}
				else {
					SubmitDossierMessage submitDossierMessage =
						new SubmitDossierMessage(context);

					submitDossierMessage.sendMessageByHornetq(
						userActionMgs.getDossierId(),
						userActionMgs.getFileGroupId());
				}

			}
			catch (Exception e) {
				_log.error(e);
			}
			finally {
				if (context != null) {
					try {
						context.destroy();
					}
					catch (JMSException e) {
						_log.error(e);
					}
					catch (NamingException e) {
						_log.error(e);
					}
				}
			}
		}

	}

	private Log _log = LogFactoryUtil.getLog(MsgInFrontOffice.class);

}
