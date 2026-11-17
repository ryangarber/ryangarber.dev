import { Card } from "@/components/ui/card";

export default function App() {
	return (
		<main className="mx-auto flex min-h-svh w-full max-w-6xl p-4 sm:p-8 lg:p-12">
			<Card
				aria-label="Site content"
				className="neon-panel min-h-[calc(100svh-2rem)] w-full sm:min-h-[calc(100svh-4rem)] lg:min-h-[calc(100svh-6rem)]"
			>
				{/* Build here. */}
			</Card>
		</main>
	);
}
