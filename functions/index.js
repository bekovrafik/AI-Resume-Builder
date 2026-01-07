const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");

admin.initializeApp();

// Initialize Gemini
// Note: In production, store API Key in Firebase Secrets
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "YOUR_API_KEY");

exports.onJdUpload = functions.firestore
    .document("users/{userId}/job_descriptions/{jdId}")
    .onCreate(async (snap, context) => {
        const data = snap.data();
        const description = data.description;
        const userId = context.params.userId;

        if (!description) return;

        try {
            const model = genAI.getGenerativeModel({ model: "gemini-pro" });
            const prompt = `
        Analyze this Job Description and extract the Top 10 Mandatory Keywords for ATS matching.
        Return ONLY a JSON array of strings.
        Job Description: "${description.substring(0, 5000)}"
      `;

            const result = await model.generateContent(prompt);
            const response = await result.response;
            let text = response.text();

            // Clean JSON
            text = text.replace(/```json/g, "").replace(/```/g, "").trim();
            const keywords = JSON.parse(text);

            // Write back to user profile for real-time matching
            await admin.firestore().collection("users").doc(userId).update({
                current_target_keywords: keywords,
                last_jd_update: admin.firestore.FieldValue.serverTimestamp(),
            });

            console.log(`Extracted ${keywords.length} keywords for user ${userId}`);

        } catch (error) {
            console.error("Error extracting keywords:", error);
        }
    });
